//
//  Conversation.h
//  InAppMessagingSampleApp
//
//  Created by Pablo Padilla on 2/11/14.
//  Copyright (c) 2014 AT&T. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IAMMessage.h"

@interface Conversation : NSObject

@property (nonatomic, copy) NSString* title;
// a unique ID for the conversation
@property (nonatomic, copy) NSString* conversationID;
// the list ordered messages, latest first
@property (nonatomic,retain) NSMutableArray* messages;

// Creates a unique ID given for the given message
+(NSString*)getConversationID:(IAMMessage*)message;
-(void)addMessage:(IAMMessage*)message;
-(void)removeMessage:(IAMMessage*)message;
-(IAMMessage*)latestMessage;
-(NSComparisonResult)compareAge:(Conversation*)conversation;
@end
