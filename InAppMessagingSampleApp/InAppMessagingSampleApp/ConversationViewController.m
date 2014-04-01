//
//  ConversationViewController.m
//  InAppMessagingSampleApp
//
//  Created by John O'Dowd on 1/23/14.
//  Copyright (c) 2014 AT&T. All rights reserved.
//

#import "ConversationViewController.h"
#import "MessageComposer.h"

#import "IAMMessage.h"
#import "MessageCell.h"
#import "TypeMetaData.h"
#import "IAMManager.h"
#import "IAMUpdateMessageRequest.h"
#import "MMSContent.h"
#import "IAMMessageContentRequest.h"
#import "SegmentationDetails.h"
#import "OutgoingConversationCell.h"
#import "IncomingConversationCell.h"
#import "IAMMessageContentRequest.h"
#import "AttachmentsViewController.h"
#import "MessageListViewController.h"

#import "Utils.h"

@interface ConversationViewController ()

@end

@implementation ConversationViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(BOOL)checkIsIos7OrLater
{
    NSArray *version = [[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."];
    if ([[version firstObject] intValue] >= 7) {
        return YES;
    }
    return NO;
}
-(void)awakeFromNib
{
    _messages = [[NSMutableArray alloc] init];
    _MessageAttachments = [[NSMutableDictionary alloc] init];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.allowsSelection = NO;
}

-(void)viewWillAppear:(BOOL)animated{

    // force data reload
    [self.tableView reloadData];
    
#if defined(__IPHONE_6_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_6_1
    // if there are messages
    if (0<_messages.count) {
        // scroll to the bottom of the table
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:
                                  [_messages count]-1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath
                              atScrollPosition:UITableViewScrollPositionBottom
                                      animated:YES];
    }
#elif defined(__IPHONE_7_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0
    // scroll to the bottom of the table
    [self.tableView setContentOffset:CGPointMake(0, CGFLOAT_MAX)];
#endif

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)downloadAttachmentsForMessage:(IAMMessage *)message
{
    //NSString *msgID = message.messageId;
   
    if (message.mmsContent) {
        NSString *msgID = message.messageId;
        for (MMSContent *content in message.mmsContent) {
             __block NSMutableArray *thisMessageAttachments = [[NSMutableArray alloc] init];
            [self.MessageAttachments setObject:thisMessageAttachments forKey:msgID];
            NSString *path = content.path;
            NSString *part = [[path componentsSeparatedByString:@"/"] lastObject];
            
            IAMMessageContentRequest *contentRequest = [[IAMMessageContentRequest alloc] init];
            contentRequest.messageId = msgID;
            contentRequest.partNumber = [part integerValue];
            [self.iamManager sendAsynchronous:contentRequest
                success:^(id result) {
                    if ([result isKindOfClass:[UIImage class]]) {
                        [thisMessageAttachments addObject:(UIImage *)result];
                    }
                    else if ([result isKindOfClass:[NSString class]]){
                        [thisMessageAttachments addObject:(NSString *)result];
                       
                    }
                } failure:^(NSError *error) {
                    NSLog(@"IAMMessageContentRequest failed:(%ld) %@",(long)error.code, error.localizedDescription);
                }];
        }
    }
}

-(IBAction)attachmentsButtonClicked:(id)sender
{
    [self performSegueWithIdentifier:@"pushAttachmentsViewControllerFromConversation" sender:sender];
}
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"pushComposeFromConversationVC"]) {
        MessageComposer *msgComposer = (MessageComposer *)segue.destinationViewController;
        // connect the delegate to the bottom viewController: `MessageListViewController`
        msgComposer.delegate= self;
        msgComposer.addresses= _replyAddress;
    }else if ([segue.identifier isEqualToString:@"pushAttachmentsViewControllerFromConversation"]){
        AttachmentsViewController *attachmentsVC = (AttachmentsViewController *)segue.destinationViewController;
        NSInteger index = [(UIButton *)sender tag];
        IAMMessage *msg = self.messages[index];
        attachmentsVC.message = msg;
        attachmentsVC.iamManager = self.iamManager;
        NSInteger textFiles = 0;
        NSInteger imageFiles = 0;
        for (MMSContent *content in msg.mmsContent) {
            if (content.type == MMSImage) {
                imageFiles++;
            }else if (content.type == MMSText){
                textFiles++;
            }
        }
        attachmentsVC.tempCountOfTextFiles = textFiles;
        attachmentsVC.tempCountOfImages = imageFiles;
    }
    
}

#pragma mark - UITableViewCell
-(ConversationCell *)setupCell:(ConversationCell*)cell forIndexPath:(NSIndexPath *)indexPath
{
    
    IAMMessage* message= self.messages[indexPath.row];
    NSString *text;
    
    // set the addressLabel
    cell.dateLabel.font= [UIFont boldSystemFontOfSize:13.0];
    
    // set the messageBodyLabel
    if (!message.text) {
        if (message.typeMetaData.subject && ![message.typeMetaData.subject isEqualToString:@""]) {
            text = message.typeMetaData.subject;
        }else {
            text = @"No Subject";
        }
    }else {
        text = message.text;
    }
    
    if (text) {
        NSMutableParagraphStyle *style =  [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        style.alignment = NSTextAlignmentNatural;
        style.firstLineHeadIndent = 10.0f;
        style.headIndent = 10.0f;
        //style.tailIndent = 10.0f;
        
        
        NSAttributedString *attrText = [[NSAttributedString alloc] initWithString:text attributes:@{ NSParagraphStyleAttributeName : style}];
        cell.messageBodyLabel.attributedText = attrText;

    }
    if (message.mmsContent) {
        cell.attachmentsButton.hidden = NO;
    } else {
        cell.attachmentsButton.hidden = YES;
    }
    cell.attachmentsButton.tag = indexPath.row;
    [cell.attachmentsButton addTarget:self action:@selector(attachmentsButtonClicked:) forControlEvents:UIControlEventTouchUpInside];

    
    CALayer *messageBodyLayer = cell.messageBodyLabel.layer;
    messageBodyLayer.masksToBounds = YES;
    messageBodyLayer.cornerRadius = 5.0;
    
    if ([cell isKindOfClass:[IncomingConversationCell class]]) {
        // light gray for incoming messages
        messageBodyLayer.backgroundColor= [UIColor colorWithRed:234/255.0f
                                                          green:233/255.0f
                                                           blue:241/255.0f
                                                          alpha:1.0f].CGColor;
        cell.textLabel.textColor= [UIColor blackColor];
    }else{
        // light blue for outgoing messages
        messageBodyLayer.backgroundColor= [UIColor colorWithRed:71/255.0f
                                                          green:181/255.0f
                                                           blue:247/255.0f
                                                          alpha:1.0f].CGColor;
        cell.textLabel.textColor= [UIColor whiteColor];
    }
    
    // set the dateLabel
    cell.dateLabel.text= [Utils formatDateForLabel:message.date];
    
    return cell;
    
}


-(ConversationCell *)setupforIOS7Cell:(ConversationCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    UIFontDescriptor *fontDescriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleBody];
    
    UIFont *font = [UIFont fontWithDescriptor:fontDescriptor size:0.0];
    cell.messageBodyLabel.font = font;
    cell.dateLabel.font = font;
    
    
    cell = [self setupCell:cell forIndexPath:indexPath];
    return cell;
}

-(ConversationCell *)setupforOldCell:(ConversationCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    
    UIFont *font = [UIFont systemFontOfSize:17.0];
    cell.messageBodyLabel.font = font;
    cell.dateLabel.font = font;
    
    cell = [self setupCell:cell forIndexPath:indexPath];
    return cell;
}

//-(IncomingConversationCell *)setupIncomingCell:(IncomingConversationCell*)cell forIndexPath:

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.messages count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *outgoingCellIdentifer = @"OutgoingCell";
    static NSString *incomingCellIdentifer = @"IncomingCell";
    IAMMessage *msg = self.messages[indexPath.row];
    
    if (msg.incoming) {
        IncomingConversationCell *cell = [tableView dequeueReusableCellWithIdentifier:incomingCellIdentifer forIndexPath:indexPath];
        if ([self checkIsIos7OrLater]) {
            cell = (IncomingConversationCell *) [self setupforIOS7Cell:cell forIndexPath:indexPath];
        } else {
            cell = (IncomingConversationCell *) [self setupforOldCell:cell forIndexPath:indexPath];
        }
               return cell;
    } else {
        OutgoingConversationCell *cell = [tableView dequeueReusableCellWithIdentifier:outgoingCellIdentifer forIndexPath:indexPath];
        if ([self checkIsIos7OrLater]) {
            cell = (OutgoingConversationCell *) [self setupforIOS7Cell:cell forIndexPath:indexPath];
        } else {
            cell = (OutgoingConversationCell *) [self setupforOldCell:cell forIndexPath:indexPath];
        }

        return cell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 132.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    static UILabel* dummyLabel;

    IAMMessage *msg = self.messages[indexPath.row];
    NSString *text = msg.text;
    if (!dummyLabel) {
        
        dummyLabel = [[UILabel alloc]
                 initWithFrame:CGRectMake(0, 0, FLT_MAX, FLT_MAX)];
        dummyLabel.text = @"test";
    }
    
    if ([self checkIsIos7OrLater]){
    dummyLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    } else{
        dummyLabel.font = [UIFont systemFontOfSize:17.0];
    }
    [dummyLabel sizeToFit];
    CGFloat singleLineLabelHeight = ceilf(dummyLabel.frame.size.height);
    CGFloat multipleLineLabelHeight = MAX(ceilf(text.length / 34.0 + 1) * singleLineLabelHeight, singleLineLabelHeight);
    return ceilf((singleLineLabelHeight * 4.0) + multipleLineLabelHeight );
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
        IAMMessage *msg = self.messages[indexPath.row];
        [self.messages removeObjectAtIndex:indexPath.row];
        NSString *msgID = msg.messageId;
        [self.delegate deleteConversationMessageWithID:msgID];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ConversationCell *cell = (ConversationCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    cell.selected = NO;
    
}


#pragma mark - UIViewDelegate
-(void)viewWillDisappear:(BOOL)animated{
    NSLog(@"Leaving this view...");
}


#pragma mark - MessageComposerDelegate

-(void)messageComposer:(MessageComposer *)composer
           sentRequest:(IAMSendMessageRequest *)attRequest{

    // add a new message to our current list of messages
    IAMMessage* message= [[IAMMessage alloc] init];
    message.text= attRequest.text;
    message.recipients= attRequest.addresses;
    message.typeMetaData.subject= attRequest.subject;
    message.date= [NSDate date];
    // if there's a subject, then it has attachments thus it MMS
    message.type= attRequest.subject? MTMMS: MTSMS;
    // add at the bottom of the list
    [_messages addObject:message];
    // redraw the view
    [self.view setNeedsDisplay];
    
    // pass the request to the bottom navController
    [self.delegate sentMessageRequest:attRequest withComposer:composer];
}
@end
