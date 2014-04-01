// Copyright (c) 2013 AT&T (htpp://developer.att.com)
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

// Helper Constants for resource parameters
extern NSString* const IAMResultsLimit;
extern NSString* const IAMResultsOffset;

extern NSString* const IAMMessageIDsFilter;
extern NSString* const IAMIsUnreadFilter;
extern NSString* const IAMMessageTypeFilter;
extern NSString* const IAMKeywordFilter;
extern NSString* const IAMIsIncomingFilter;

#import "ATTRequest.h"


@interface IAMMessagesListRequest : ATTRequest

/// Number of messages to fetch.
/// Default value: 50
/// Max value: 500 messages. If you set this value
/// to more than 500, it will be ignored and 500 will be used.
@property (nonatomic) NSInteger limit;

/// The starting point in the ordered list of results
/// Default value: 0
@property (nonatomic) NSInteger offset;

// if set, the response will contain only messages whose
// ids are in the array. This will override any other parameter.
@property (nonatomic, retain) NSArray* messageIDsFilter;

// if set to YES, will filter out messages that have been read
@property (nonatomic) BOOL filterUnread;

// defines the messages types to filter from the results
// types are defined by the enum IAMMessageType
// By default the filter is: SMS, MMS
@property (nonatomic, retain) NSArray* typesFilter;

// if set, it will filter out messages not containing the keyword.
@property (nonatomic, copy) NSString* keywordFilter;

/// Filter messages by their `isIncoming` property
@property (nonatomic) BOOL incoming;

@end
