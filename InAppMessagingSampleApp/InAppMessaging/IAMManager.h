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

#import <Foundation/Foundation.h>
#import "ATTRequestManager.h"

@class ATTRequest, IAMParser;

/** This subclass encapsulates the state information of an HTTP client
 that consumes the AT&T In-App Messaging API.
 */
@interface IAMManager : ATTRequestManager

/// @name Accessing the manager properties.

/** The state of the mailbox in the platform.
 */
@property (nonatomic,readonly, copy) NSString* mailboxState;

#pragma mark - Convenience methods

///------------
/// @name Sending messages
///-------------

/** Sends an SMS message to the specified `addresses`.
 
 @param text The text of the SMS message
 @param addresses A comma-separated list of numbers, e-mail or shortcodes.
 @param failure A block to process the error in case the request fails.
 
 **/
-(void)sendSMS:(NSString*)text to:(NSString*)addresses
       failure:(void (^)(NSError*))failure;

/// @name Getting the messages from the server

/** Get message list with default parameters.
 
    @param success A block to process the list of messages.
    @param failure A block to process the error in case the request fails.
 
 @discussion The default values are:
 * `limit = 50`
 * `offset= 0`
 */
-(void)getAllMessages:(void (^)(NSArray*))success
              failure:(void (^)(NSError*))failure;

@end
