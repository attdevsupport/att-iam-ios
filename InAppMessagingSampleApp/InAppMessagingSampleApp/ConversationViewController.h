//
//  ConversationViewController.h
//  InAppMessagingSampleApp
//
//  Created by John O'Dowd on 1/23/14.
//  Copyright (c) 2014 AT&T. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageComposer.h"
#import "IAMSendMessageRequest.h"

@class IAMManager;

@protocol ConversationMessagesUpdatedDelegate <NSObject>

-(void)favoritesUpdated;
-(void)deleteConversationMessageWithID:(NSString*)msgID;
-(void)sentMessageRequest:(IAMSendMessageRequest*)attRequest withComposer:(MessageComposer*)composer;
@end

@interface ConversationViewController : UITableViewController<MessageComposerDelegate>
@property (nonatomic, weak) id<ConversationMessagesUpdatedDelegate> delegate;
@property (nonatomic, retain) NSString* replyAddress;
@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, retain) NSDictionary *contactsIndex;
@property (nonatomic, strong) NSMutableDictionary *MessageAttachments;
@property (nonatomic, strong) IAMManager *iamManager;
@end
