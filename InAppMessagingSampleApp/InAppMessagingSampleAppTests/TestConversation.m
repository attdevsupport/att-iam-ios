//
//  TestsConversation.m
//  InAppMessagingSampleApp
//
//  Created by Pablo Padilla on 2/11/14.
//  Copyright (c) 2014 AT&T. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "IAMMessage.h"
#import "Conversation.h"

@interface TestConversation : XCTestCase

@end

@implementation TestConversation

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testGetConversationID{
    
    IAMMessage* message= [[IAMMessage alloc] init];
    
    // Case 1:
    message.from= @"+10000000003";
    message.recipients= @[@"+10000000000", @"+10000000001", @"+10000000002"];
    NSString* conversationID= [Conversation getConversationID:message];
    NSString* extectedID= [@[@"+10000000000", @"+10000000001",
                             @"+10000000002", @"+10000000003"] componentsJoinedByString:@","];
    XCTAssertTrue([extectedID isEqualToString:conversationID], @"Wrong conversation ID");
    
    // Case 2:
    message.from= @"+12489992345";
    message.recipients= @[@"+12489792345", @"+12489932345", @"+14259992346"];
    conversationID= [Conversation getConversationID:message];
    extectedID= [@[@"+12489792345", @"+12489932345",
                   @"+12489992345", @"+14259992346"] componentsJoinedByString:@","];
    
    XCTAssertTrue([extectedID isEqualToString:conversationID], @"Wrong conversation ID");
    
}

@end
