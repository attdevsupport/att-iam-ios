//
//  ViewController.m
//  InAppMessagingSampleApp
//
//  Created by John O'Dowd on 1/20/14.
//  Copyright (c) 2014 AT&T. All rights reserved.
//

#import "IAMManager.h"
#import "IAMMessage.h"
#import "ATTAppConfiguration.h"
#import "ATTOAuthViewcontroller.h"
#import "OAuthToken.h"
#import "NSString+IAMUtils.h"
#import "IAMDeleteMessageRequest.h"
#import "IAMDeltasUpdateRequest.h"
#import "NSObject+Description.h"
#import "IAMMessageIndexInfoRequest.h"
#import "IAMMessageIndexInfo.h"
#import "IAMDelta.h"
#import "IAMMessagesListRequest.h"
#import "IAMDeltaDetail.h"
#import "TypeMetaData.h"
#import "IAMUpdateMessagesRequest.h"
#import "MessageComposer.h"
#import "MessageCell.h"
#import "MessageListViewController.h"
#import "AppDelegate.h"
#import "ConversationViewController.h"
#import "SegmentationDetails.h"
#import "IAMDeleteMessagesRequest.h"
#import "Utils.h"
#import "ContactConvertor.h"
#import "IAMCreateMessageIndexRequest.h"
#import "Conversation.h"


@interface MessageListViewController () <ATTOAuthConsent, MessageComposerDelegate,
ConversationMessagesUpdatedDelegate>

@property (strong) __block NSMutableArray *messages;
@property (nonatomic, strong) NSDictionary *contactsIndex;
@property (nonatomic, strong) NSMutableArray *messagesNotToBeIncludedInList;
@property (nonatomic, strong) IAMManager *iamManager;
@property (nonatomic, strong) __block NSMutableArray *conversations;
@property (nonatomic, strong) NSMutableArray *contactsMessagesForEachConversation;
@property (nonatomic, strong) NSMutableDictionary *replacementStringsForMultipartMessages;
@property (nonatomic, strong) NSString *inboxNumber;
@property (nonatomic, retain) UIAlertView* confirmLogoutDialog;
@property (nonatomic, retain) UIAlertView *inboxNumberDialog;
@property (nonatomic, retain) UITextField *inboxNumberTextField;
@end

@implementation MessageListViewController
{
    UIActivityIndicatorView *_activityIndicator;
    BOOL _isFirstLoad;
    ATTOAuthViewController* _oauthVC;
}
-(BOOL)checkIsIos7OrLater
{
    NSArray *version = [[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."];
    if ([[version firstObject] intValue] >= 7) {
        return YES;
    }
    return NO;
}

-(BOOL)isPhoneNumber
{
    return NO;
    
}


#pragma mark - Log In & Log Out

-(void)setupLogOutButton{
    // enable new message button
    self.navigationItem.rightBarButtonItem.enabled= YES;
    
    self.navigationItem.leftBarButtonItem.title= @"Log Out";
    self.navigationItem.leftBarButtonItem.target= self;
    self.navigationItem.leftBarButtonItem.action= @selector(logout:);
}

-(void)setupLogInButton{
    self.navigationItem.leftBarButtonItem.title= @"Log In";
    self.navigationItem.leftBarButtonItem.target= self;
    self.navigationItem.leftBarButtonItem.action= @selector(login:);

    // disable new message button
    self.navigationItem.rightBarButtonItem.enabled=NO;
}

-(void)login:(id)sender{
    [self showInboxNumberDialog];
}

-(void)showInboxNumberDialog{
    _inboxNumberDialog = [[UIAlertView alloc] initWithTitle:@"Phone number"
                                                    message:@"Enter the inbox phone number:"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Ok", nil];
    _inboxNumberDialog.alertViewStyle = UIAlertViewStylePlainTextInput;
    _inboxNumberTextField= [_inboxNumberDialog textFieldAtIndex:0];
    
    [_inboxNumberDialog show];
}

- (IBAction)logout:(id)sender {
    
    // ask for confirmation
    
    _confirmLogoutDialog= [[UIAlertView alloc] initWithTitle:@"Confirmation"
                                                    message:@"By logging out you will delete the cached token and the current messages. Confirm?"
                                                   delegate:self cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"OK", nil];
    
    [_confirmLogoutDialog show];
}

-(void)deleteCachedToken{

    // clear the cached token
    [ATTOAuthClient clearCachedToken];
    
    // delete the current token
    [_iamManager setOauthToken:nil];
    // delete all cookies for this domain
    NSHTTPCookieStorage* cookieStorage= [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray* cookies= [cookieStorage cookiesForURL:_iamManager.appConfig.baseURL];
    for (NSHTTPCookie *cookie in cookies) {
        [cookieStorage deleteCookie:cookie];
    }
    
    _messages= nil;
    _contactsIndex= nil;
    _messagesNotToBeIncludedInList= nil;
    _conversations= nil;
    _contactsMessagesForEachConversation= nil;
    _replacementStringsForMultipartMessages= nil;
    
    [self.tableView reloadData];
    
}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{

    if (alertView == _inboxNumberDialog) {
        // cancel button does nothing
        if (buttonIndex == alertView.cancelButtonIndex) {
            return;
        }
        
        // if the number is invalid (shorter than 10 digits), show alert
        if (10>_inboxNumberTextField.text.length) {
            [self showAlert:@"Error" message:@"Invalid number, enter a valid number"];
            return;
        }

        // the number is a valid phone number
        // use the value in the phone number as the inbox number
        _inboxNumber= _inboxNumberTextField.text;
        
        // start doing
        [self initMessagesData];
        [self updateInitialState];
        
        return;
    }
    
    if (alertView==_confirmLogoutDialog) {
        // if the user cancels
        if (buttonIndex == alertView.cancelButtonIndex) {
            // do nothing
            return;
        }
        
        // delete the cached token
        [self deleteCachedToken];
        // change the behavior of the nav bar button
        [self setupLogInButton];
    }
    
    // for any other alert view, cancel does nothing
    if (buttonIndex == alertView.cancelButtonIndex) {
        return;
    }
}

#pragma mark - IAMManager


-(void)setupMultipartMessagesForMessage:(IAMMessage *)message
{
    NSString *tempString = @"";
    NSInteger reference;
    NSString *msgID;
    
    if (message.typeMetaData.details) {
        NSMutableArray *messagesWithPartsOfMessage = [[NSMutableArray alloc] init];
        [messagesWithPartsOfMessage addObject:message];
        
        //tempString = message.text;
        msgID = message.messageId;
        reference = message.typeMetaData.details.reference;
        // find all the parts for the current message
        for (IAMMessage *msg in self.messages) {
            if (reference == msg.typeMetaData.details.reference
                && ![msgID isEqualToString:msg.messageId]) {
                // add the parts found
                [messagesWithPartsOfMessage addObject:msg];
            }
        }
        // order the parts by date
        [messagesWithPartsOfMessage sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            IAMMessage *msg1 = (IAMMessage *)obj1;
            IAMMessage *msg2 = (IAMMessage *)obj2;
            return [msg2.date compare:msg1.date];
        }];
        
        // create the text for the final message by concatenating
        // the text of the message parts
        for (IAMMessage *aMessage in messagesWithPartsOfMessage) {
            tempString = [tempString stringByAppendingString:aMessage.text];
        }
        

        for (IAMMessage *theMessage in messagesWithPartsOfMessage) {
            // this is the whole text for the segmented message
            [self.replacementStringsForMultipartMessages setObject:tempString
                                                            forKey:theMessage.messageId];
            // mark irrelevant parts of a message not to be shown in the list
            [self.messagesNotToBeIncludedInList addObject:theMessage];
        }
        
        // TODO: Why do we remove the last message in this list
        [self.messagesNotToBeIncludedInList removeLastObject];
        
        
    }
}

// generates an index of conversations for easy access
-(NSDictionary*)conversationsIndexFor:(NSArray*)conversations{
    NSMutableDictionary* index= [NSMutableDictionary dictionary];
    for (Conversation* conversation in conversations) {
        (index)[conversation.conversationID]= conversation;
    }
    
    return index;
}

-(NSArray*)conversationsFromMessages:(NSArray*)messages{

    // use the existing conversation as a starting point
    NSMutableArray* conversations= [NSMutableArray array];
    NSString* conversationID= nil;
    
    for (IAMMessage* currentMessage in messages) {
        // identify the conversation this message belongs to
        conversationID= [Conversation getConversationID:currentMessage];
        
        // get the latest index of converstions
        NSDictionary* conversationsIndex= [self conversationsIndexFor:conversations];
        // if the conversation already exists
        if ([[conversationsIndex allKeys] containsObject:conversationID]) {
            Conversation* existingConv= (conversationsIndex)[conversationID];
            // add the message to the conversation
            [existingConv addMessage:currentMessage];
            // this message is done, get the next message
            continue;
        }
        
        // the conversationID is NOT in our index of conversations
        // create a new conversation
        Conversation* newConversation= [[Conversation alloc] init];
        newConversation.conversationID= conversationID;
        // add the current message to the conversation
        [newConversation addMessage: currentMessage];
        // add the new conversation
        [conversations addObject:newConversation];
        // we're done with this message, go to the next
        continue;
    }
    
    // sort the list of conversations, latest first
    return [conversations sortedArrayUsingSelector:@selector(compareAge:)];
}


-(NSMutableArray *)getListOfMessagesForAConversationAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *contact = self.conversations[indexPath.row];
    // get the array of contacts
    NSMutableArray *contactArray = [[contact componentsSeparatedByString:@","] mutableCopy];
    
    // if there are more than one contact
    if ([contactArray count] > 1
        // and my number is in it
        &&[contactArray containsObject:[self inboxNumber]]) {
        // remove my number from the contacts array
        [contactArray removeObject:[self inboxNumber]];
    }
    
    // TODO: change sintax
    NSMutableArray *conversationMessages = [[NSMutableArray alloc] init];

    // for each message in all the messages we have downloaded
    for (IAMMessage *msg in _messages) {
        if ([contactArray count] == 1) {// only one
            if (msg.incoming) {
                
                if ([msg.from isEqualToString:[contactArray lastObject]]) {
                    [conversationMessages addObject:msg];
                }
            } else {
                NSArray *recipients = msg.recipients;
                if ([recipients isEqualToArray:contactArray]) {
                    [conversationMessages addObject:msg];
                }
            }
        }
        else {
            // handle group message where the conversation is between the user and a number of other people

            NSArray *recipients = msg.recipients;
            // as the contactArray was created from a String that was created from a sorted Array
            // sort the recipients into the same order before comparing.
            recipients = [recipients sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                NSString *first = (NSString *)obj1;
                NSString *second = (NSString *)obj2;
                return [first compare:second];
            }];
            
            if (msg.incoming) {
                // Check if the message comes from one of the contacts in group and
                if ([contactArray containsObject:msg.from]) {
                    [contactArray removeObject:msg.from];
                    [contactArray addObject:[self inboxNumber]];
                    [contactArray sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                        NSString *first = (NSString *)obj1;
                        NSString *second = (NSString *)obj2;
                        return [first compare:second];
                    }];
                    if ([contactArray isEqualToArray:recipients]) {
                        [conversationMessages addObject:msg];
                    }
                }
            }
            else {
                // as the user sent the message, for it to be in the same group, the recipients should equal
                // the list of other contacts in the contactArray
                if ([recipients isEqualToArray:contactArray]) {
                    [conversationMessages addObject:msg];
                }
            }
            
        }
    }
    [conversationMessages sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSDate *firstDate = [(IAMMessage*)obj1 date];
        NSDate *secondDate = [(IAMMessage *)obj2 date];
        return [secondDate compare:firstDate];
    }];
    
    for (IAMMessage *msg in self.messagesNotToBeIncludedInList) {
        if ([conversationMessages containsObject:msg]) {
            [conversationMessages removeObject:msg];
        }
    }
    for (IAMMessage *msg in conversationMessages) {
        if (self.replacementStringsForMultipartMessages[msg.messageId]) {
            msg.text = self.replacementStringsForMultipartMessages[msg.messageId];
        }
    }
    return conversationMessages;
}


-(void)deleteMessageWithId:(NSString*)msgID
{

    IAMDeleteMessageRequest *deleteMsgRequest = [[IAMDeleteMessageRequest alloc] init];
    deleteMsgRequest.messageId = msgID;
    [_iamManager sendAsynchronous:deleteMsgRequest success:^(id result){
         [self performDeltaUpdate];
     } failure:^(NSError *error) {
         NSLog(@"Unable to delete Message %@ from Server: %@",msgID, error.localizedDescription);
         [self showAlert:@"Error" message:error.localizedDescription];
     }];
    
    
}

-(void)deleteMessages:(NSArray*)messages
{
    IAMDeleteMessagesRequest *deleteMsgsRequest = [[IAMDeleteMessagesRequest alloc] init];
    deleteMsgsRequest.messages = messages;
    [self.iamManager sendAsynchronous:deleteMsgsRequest
        success:^(id result) {
            
            [self performDeltaUpdate];
        } failure:^(NSError *error) {
            NSLog(@"IAMDeleteMessagesRequest failed: (%ld) %@",(long)error.code, error.description);
            [self showAlert:@"Error" message:error.localizedDescription];
        }];
    
}
-(void)getNewMessagesWithIDs:(NSArray *)msgIDsToRequest{
    IAMMessagesListRequest *msgRequest =  [[IAMMessagesListRequest alloc] init];
    msgRequest.messageIDsFilter = [msgIDsToRequest copy];
    
    __weak MessageListViewController *weakSelf = self;
    
    // request the messages
    [_iamManager sendAsynchronous:msgRequest success:^(id messages) {
        if (weakSelf) {
            MessageListViewController *strongSelf = weakSelf;
            // add the new message to our list of messages
            [_messages addObjectsFromArray:messages];
            // recalculate the conversations
            _conversations= [NSMutableArray arrayWithArray:[self conversationsFromMessages:_messages]];
            // reload the table view
            [strongSelf.tableView reloadData];
        }
        
        
    } failure:^(NSError *error) {
        NSLog(@"Unable to retrieve Messages with IDs %@  from Server: %@",
              msgIDsToRequest, error.localizedDescription);
        [self showAlert:@"Error" message:error.localizedDescription];
    }];

}

-(void)performDeltaUpdate{
    IAMDeltasUpdateRequest *deltaRequest = [[IAMDeltasUpdateRequest alloc] init];
    deltaRequest.state = _iamManager.mailboxState;
    
    // request new deltas
    [_iamManager sendAsynchronous:deltaRequest success:^(id result){
         NSArray *array = (NSArray *)result;
        
         // for each delta update
         for (IAMDelta *delta in array) {
             // get the content of the added messages
             NSArray *additions = delta.additions;
             if ([additions count] > 0) {
                 NSMutableArray *msgIDsToRequest = [[NSMutableArray alloc] init];
                 for (IAMDeltaDetail *detail in additions) {
                     [msgIDsToRequest addObject:detail.messageId];
                 }
                 // get the new messages
                 [self getNewMessagesWithIDs:msgIDsToRequest];
             }
             // update the local messages with the latest flags
             if ([delta.updates count] > 0) {
                 for (IAMDeltaDetail* detail in delta.updates) {
                     NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.messageId contains %@", detail.messageId];
                     NSArray *filteredArray = [_messages filteredArrayUsingPredicate:predicate];
                     IAMMessage *msg = (IAMMessage *)[filteredArray lastObject];
                     msg.unread = detail.unread;
                     msg.favorite = detail.favorite;
                 }
             }
             // delete the local messages
             if ([delta.deletions count] > 0) {
                 for (IAMDeltaDetail* detail in delta.deletions) {
                     NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.messageId contains %@", detail.messageId];
                     // find local messages to delete
                     NSArray *filteredArray = [_messages filteredArrayUsingPredicate:predicate];
                     [_messages removeObject:[filteredArray lastObject]];
                     // recalculate conversations
                     _conversations= nil;
                     _conversations= [NSMutableArray arrayWithArray:[self conversationsFromMessages:_messages]];
                 }
             }
             [self.tableView reloadData];
         }
     } failure:^(NSError *error){
         NSLog(@"Unable to retrieve Message Deltas from Server: %@", error.localizedDescription);
         [self showAlert:@"Error" message:error.localizedDescription];
     }];
    
}
- (void)updateInitialState{
    
    IAMMessageIndexInfoRequest *indexInfoRequest = [[IAMMessageIndexInfoRequest alloc] init];
    [self showActivityIndicator];
    [_iamManager sendAsynchronous:indexInfoRequest success:^(id indexInfo){
        
        [self hideActivityIndicator];
        
        // check if the index is in a valid state
        IAMMessageIndexInfo* index= indexInfo;
        if (index.indexCacheStatus == ICSNotInitialized // if the index is not initialized
            || index.indexCacheStatus == ICSError ) {
            // initialize the index
            IAMCreateMessageIndexRequest* createIndexRequest= [[IAMCreateMessageIndexRequest alloc] init];
            
            [_iamManager sendAsynchronous:createIndexRequest success:^(id result) {
                NSLog(@"Index Initialization succesful!");
                // try to initialize the app again
                [self updateInitialState];
            } failure:^(NSError *error) {
                NSLog(@"Error Initializing the index!");
                [self showAlert:@"Error" message:error.localizedDescription];
            }];
            
            // stop execution until we get a valid index
            return;
        }else if(index.indexCacheStatus == ICSInitialized){ // the index is valid
            // the mailbox state is updated automatically
            // get the latest messages
            [self getInitialMessages];
        }
    }failure:^(NSError *error){
        [self hideActivityIndicator];
        NSLog(@"Unable to retrieve Index Info from Server: %@",
              error.localizedDescription);
        [self showAlert:@"Error" message:error.localizedDescription];
    }];
}

-(void)getInitialMessages{
    
    [_iamManager getAllMessages:^(NSArray* messages){
        // if we got the messages it means we are already logged in
        [self setupLogOutButton];
        
        [_messages addObjectsFromArray:messages];
        NSLog(@"messages: %@",[_messages getPropertiesDictionary]);
        // calculate conversations for the given messages
        NSArray* conversations= [self conversationsFromMessages:_messages];
        // add those conversation to our list
        [_conversations addObjectsFromArray: conversations];
        // create the contacts index for the conversations
        _contactsIndex= [self createContactsIndex:_conversations];
        
        // refresh the table view
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        NSLog(@"Couln't get messages, try again: %@",error.localizedDescription);
        [self showAlert:@"Error" message:error.localizedDescription];
    }];
}

-(NSDictionary*)createContactsIndex:(NSArray*)conversations{

    NSDictionary* index=nil;
    NSMutableSet* numbers= [NSMutableSet set];
    
    // add the numbers for all conversations
    for (Conversation* conversation in conversations) {
        NSArray* numbersForConversation= [conversation.conversationID componentsSeparatedByString:@","];
        [numbers addObjectsFromArray: numbersForConversation];
    }
    
    index= [ContactConvertor contactNamesForNumbers:[numbers allObjects]];
    
    return index;
}


#pragma mark - UIViewController


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)initMessagesData{

    self.messages = [NSMutableArray array];
    _conversations = [NSMutableArray array];
    
    self.replacementStringsForMultipartMessages = [[NSMutableDictionary alloc] init];
    self.messagesNotToBeIncludedInList = [[NSMutableArray alloc] init];
    _isFirstLoad = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // setup the request manager
    AppDelegate *myAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    ATTAppConfiguration *appConfig = myAppDelegate.appConfig;
    _iamManager= [[IAMManager alloc] initWithConfig:appConfig andDelegate:self];

    // promt the user for the inbox number so we can identify it in the conversations
    [self showInboxNumberDialog];
    
    // setup the activity indicator
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
                          UIActivityIndicatorViewStyleWhiteLarge];
    _activityIndicator.center = CGPointMake(self.view.frame.size.width / 2.0,
                                            self.view.frame.size.height / 2.0);
    _activityIndicator.backgroundColor= [UIColor darkGrayColor];

    // the initial action of the left bar button in the navigation bar is to "Log In"
    [self setupLogInButton];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _isFirstLoad = NO;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"pushComposeFromAllMessages"]) {
        MessageComposer* messageComposer = (MessageComposer *)segue.destinationViewController;
        messageComposer.delegate = self;

    }
    else if ([segue.identifier isEqualToString:@"loadComposer"]) {
        MessageComposer* target= segue.destinationViewController;
        target.delegate= self;
    }
    else if ([segue.identifier isEqualToString:@"pushConversationFromAllMessages"]){
        ConversationViewController *conversationVC = (ConversationViewController *)segue.destinationViewController;
        conversationVC.delegate= self;
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Conversation* conversation= _conversations[indexPath.row];
        NSMutableArray *conversationMessages=  conversation.messages;
        
        for (IAMMessage *msg in conversationMessages) {
            msg.unread = NO;
        }
        
        IAMUpdateMessagesRequest *updateMsgsRequest = [[IAMUpdateMessagesRequest alloc] init];
        updateMsgsRequest.messages = [conversationMessages copy];
        [self.iamManager sendAsynchronous:updateMsgsRequest
            success:^(id result) {
                [self performDeltaUpdate];
            } failure:^(NSError *error) {
                NSLog(@"IAMUpdateMessagesRequest failed: %@", error.localizedDescription);
                [self showAlert:@"Error" message:error.localizedDescription];
            }];
        
        conversationVC.messages= conversationMessages;
        conversationVC.replyAddress= [self uniqueReplyAdressesFor:conversation];
        conversationVC.contactsIndex = _contactsIndex;
        conversationVC.title = conversation.title;
        conversationVC.iamManager = self.iamManager;
        conversationVC.delegate = self;
        
    }
    
}

-(NSString*)uniqueReplyAdressesFor:(Conversation*)conversation{
 
    // remove the inbox's number
    NSString* replyAddress= conversation.conversationID;
    // delete duplicate addresses
    NSMutableSet* uniqueAddresses= [NSMutableSet setWithArray:
                                    [replyAddress componentsSeparatedByString:@","]];
    // remove emtpy strings
    [uniqueAddresses removeObject:@""];
    // remove inbox number
    NSPredicate* notContainInbox= [NSPredicate predicateWithFormat:@"NOT(SELF CONTAINS[cd] %@)", _inboxNumber];
    [uniqueAddresses filterUsingPredicate:notContainInbox];
    // get comma-separated string with unique numbers to reply
    replyAddress= [[uniqueAddresses allObjects] componentsJoinedByString:@","];
    
    return replyAddress;
}

#pragma mark - UITableViewCell

-(NSString*)titleFor:(Conversation*)conversation{
    
    // get the latest message for this conversation
    IAMMessage* message= [conversation latestMessage];
    
    // configure the conversation's title ( addressLabel )
    NSString* conversationTitle= nil;
    
    // if this is a group message
    if (1<message.recipients.count) {
        conversationTitle= @"Group Message";
    }else{// this is a 1-to-1 message
        // I'm the recipient
        if (message.incoming) {
            // use the sender's name
            conversationTitle= (_contactsIndex)[message.from];
            conversationTitle= conversationTitle?conversationTitle:message.from;
        }else{// I'm the sender
            // use the recipients name
            conversationTitle= (_contactsIndex)[[message.recipients firstObject]];
            conversationTitle= conversationTitle? conversationTitle: [message.recipients firstObject];
        }
    }
    
    return conversationTitle;
}

-(MessageCell *)setupCell:(MessageCell*)cell forIndexPath:(NSIndexPath *)indexPath
{
    Conversation* conversation = _conversations[indexPath.row];
    
    // set the converstation title as the address label for this cell
    conversation.title= [self titleFor:conversation];
    cell.addressLabel.text= conversation.title;
    
    IAMMessage* message= [conversation latestMessage];
    NSString *messageBody;
    // set the messageBodyLabel
    // if the message text's is emtpy
    if (!message.text) {
        // if the message has a subject
        if (message.typeMetaData.subject
            // AND the subject is NOT emtpy
            && ![message.typeMetaData.subject isEqualToString:@""]) {
            // use the subject for the message's body
            messageBody = message.typeMetaData.subject;
        }else { // the message has not subject
            messageBody = @"No Subject";
        }
    }else {// the message HAS text
        messageBody = message.text;
    }
    
    // if the message is in our list of segmented messages
    if (self.replacementStringsForMultipartMessages[message.messageId]) {
        // use the replacement text as the body of this message
        messageBody = self.replacementStringsForMultipartMessages[message.messageId];
    }
    
    // set the message body label for this cell
    cell.messageBodyLabel.text= messageBody;
    
    // set the formated date label
    cell.dateLabel.text = [Utils formatDateForLabel:message.date];
    
    return cell;
    
}


-(MessageCell *)setupforIOS7Cell:(MessageCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    UIFontDescriptor *fontDescriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleBody];
    
    Conversation* conversation= _conversations[indexPath.row];
    // get the latest message for this conversation
    IAMMessage *msg = [conversation latestMessage];
    
    if (msg.unread){
        UIFontDescriptor *boldFontDescriptor = [fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
        UIFont *boldFont = [UIFont fontWithDescriptor:boldFontDescriptor size:0.0];
        cell.messageBodyLabel.font = boldFont;
        cell.dateLabel.font = boldFont;
        cell.addressLabel.font = boldFont;
        
    } else {
        UIFont *font = [UIFont fontWithDescriptor:fontDescriptor size:0.0];
        cell.messageBodyLabel.font = font;
        cell.dateLabel.font = font;
        cell.addressLabel.font = font;
    }
    
    cell = [self setupCell:cell forIndexPath:indexPath];
    return cell;
}

-(MessageCell *)setupforOldCell:(MessageCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    Conversation* conversation= _conversations[indexPath.row];
    // get the latest message for this conversation
    IAMMessage *msg= [conversation latestMessage];
    
    if (msg.unread){
        UIFont *boldFont = [UIFont boldSystemFontOfSize:17.0];
        cell.messageBodyLabel.font = boldFont;
        cell.dateLabel.font = boldFont;
        cell.addressLabel.font = boldFont;
        
        
    } else {
        UIFont *font = [UIFont systemFontOfSize:17.0];
        cell.messageBodyLabel.font = font;
        cell.addressLabel.font = font;
        cell.dateLabel.font = font;
    }
    cell = [self setupCell:cell forIndexPath:indexPath];
    return cell;
}


#pragma mark - UITableView

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _conversations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if ([self checkIsIos7OrLater]) {
        [self setupforIOS7Cell:cell forIndexPath:indexPath];
    }
    else {
        [self setupforOldCell:cell forIndexPath:indexPath];
    }
    return cell;
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        Conversation* conversation= _conversations[indexPath.row];
        // delete the selected conversation from the list
        [_conversations removeObject:conversation];
        // delete all messages for this conversation
        [self deleteMessages:conversation.messages];
        // delete the row from the table view
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    }   
}

#pragma mark - MessageComposerDelegate

-(void)messageComposer:(MessageComposer *)composer
           sentRequest:(IAMSendMessageRequest *)attRequest{
    
    [self showActivityIndicator];
    
    [_iamManager sendAsynchronous:attRequest success:^(id messageId) {
        
        [self hideActivityIndicator];
        
        // Show an alert dialog to make it look formal
        UIAlertView* alert= [[UIAlertView alloc] initWithTitle:@"Success!"
                                                       message:@"Message sent!"
                                                      delegate:self
                                             cancelButtonTitle:@"Ok"
                                             otherButtonTitles:nil];
        [alert show];
        
        // if successful dismiss the top MessageComposer
        [self.navigationController popViewControllerAnimated:YES];
        
        // update messages
        [self performDeltaUpdate];
        
    } failure:^(NSError *error) {
        
        [self hideActivityIndicator];
        
        NSLog(@"ERROR: %@", error.localizedDescription);
        NSString* message= error.localizedDescription;
        UIAlertView* alert= [[UIAlertView alloc] initWithTitle:@"FATAL ERROR"
                                                       message:message
                                                      delegate:self
                                             cancelButtonTitle:@"Ok"
                                             otherButtonTitles:nil];
        [alert show];
    }];
    
}

#pragma mark - ConversationMessagesUpdatedDelegate
-(void)favoritesUpdated
{
    
}

// forward request to appropiate method
-(void)sentMessageRequest:(IAMSendMessageRequest *)attRequest
             withComposer:(MessageComposer *)composer{
    [self messageComposer:composer sentRequest:attRequest];
}

#pragma mark - Helper methods

-(void)showActivityIndicator{
    self.navigationController.visibleViewController.view.userInteractionEnabled= NO;
    [self.navigationController.visibleViewController.view addSubview:_activityIndicator];
    [_activityIndicator startAnimating];
}

-(void)hideActivityIndicator{
    
    [_activityIndicator stopAnimating];
    [_activityIndicator removeFromSuperview];
    self.navigationController.visibleViewController.view.userInteractionEnabled=YES;
}

-(void)deleteConversationMessageWithID:(NSString*)msgID
{
    [self deleteMessageWithId:msgID];
}

// show a generic alert
-(void)showAlert:(NSString*)title message:(NSString*)message{

    UIAlertView* confirmDialog= [[UIAlertView alloc] initWithTitle:title
                                                           message:message
                                                          delegate:self cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil];
    [confirmDialog show];

}
#pragma mark - ATTOAuthConsent

-(void)showAuthorizationPage{
    
    AppDelegate *myAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _oauthVC= [[ATTOAuthViewController alloc] init];
    _oauthVC.delegate= self;
    [_oauthVC setConfiguration:myAppDelegate.appConfig];
    
    [self presentViewController:_oauthVC animated:YES completion:nil];
}

-(void)didCancel{
    if (![self.presentedViewController isBeingDismissed]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    [self hideActivityIndicator];
}

-(void)didGetToken:(OAuthToken *)token{
    
    // use the token just received
    _iamManager.oauthToken= token;
    
    if (![self.presentedViewController isBeingDismissed]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    // setup the log out button
    [self setupLogOutButton];
    
    [self updateInitialState];
}

-(void)didFailToObtainToken:(NSError *)error{
    
    NSLog(@"%@", error);
    if (![self.presentedViewController isBeingDismissed]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


@end
