//
//  Conversation.m
//  InAppMessagingSampleApp
//
//  Created by Pablo Padilla on 2/11/14.
//  Copyright (c) 2014 AT&T. All rights reserved.
//

#import "Conversation.h"
#import "IAMMessage.h"

@implementation Conversation

-(void)removeMessage:(IAMMessage *)message{
    if ([_messages containsObject:message]) {
        [_messages removeObject:message];
    }else{
        NSLog(@"Nothing remove, message: %@ is not in this conversation.",
              message.messageId);
    }
}

// add the message at the appropiate location within the
// sorted messages array, oldest first
-(void)addMessage:(IAMMessage *)message{

    // the the messages list hasn't been created
    if (!_messages) {
        // create the list
        _messages= [NSMutableArray array];
        // add the message
        [_messages addObject:message];
        return;
    }
    
    // the message list is emtpy
    if (0==_messages.count) {
        [_messages addObject:message];
        return;
    }
    
    // the message already has messages
    
    NSInteger insertionIndex= 0;
    // find the appropriate index to insert the message
    for (IAMMessage* currentMessage in _messages){
        // if `message` is older than `currentMessage`
        if (NSOrderedAscending==[message.date compare:currentMessage.date]) {
            // we will insert `message` before the current message
            // will shift `currentMessage` one position
            insertionIndex= [_messages indexOfObject:currentMessage];
            [_messages insertObject:message atIndex:insertionIndex];
            return;
        }
    }

    // we have looped the whole array, it means the message
    // is newer than the rest an we should insert it at the end of the list
    [_messages addObject:message];
    
    return;
}


+(NSString *)getConversationID:(IAMMessage *)message{

    NSString* conversationID= nil;
    
    NSMutableArray* numbersInConversation= [NSMutableArray arrayWithArray:message.recipients];
    
    // order the numbers
    NSArray* orderedNumbers = [numbersInConversation sortedArrayUsingComparator:
                               ^NSComparisonResult(id obj1, id obj2) {
                                   NSString *first = (NSString *)obj1;
                                   NSString *second = (NSString *)obj2;
                                   return [first compare:second];
                               }];
    
    // the conversationID is the ordered concatenation of all the
    // numbers involved in this message.
    conversationID= [orderedNumbers componentsJoinedByString:@","];
    
    return conversationID;
}

-(IAMMessage *)latestMessage{
    return [_messages lastObject];
}

-(NSComparisonResult)compareAge:(Conversation *)conversation{
    return [[conversation latestMessage].date
            compare:[self latestMessage].date];
}
@end
