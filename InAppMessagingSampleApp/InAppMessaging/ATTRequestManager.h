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
#import "ATTOAuthClient.h"

@class AFHTTPClient, AFHTTPRequestOperation, ATTRequestManager, ATTRequest,
OAuthToken, ATTAppConfiguration;

///----------------------------------------------------
/// @name `UserInfo` dictionary keys on request failure
///----------------------------------------------------

/**
 Used to extract the information from the `UserInfo` dictionary that is
 returned when a request fails.
 
 They are also used to create our custom errors trying to have a
 cleaner presentation of the error.
 */
extern NSString* const ATTRequestErrorKey;
extern NSString* const ATTServiceException;
extern NSString* const ATTExceptionID;
extern NSString* const ATTExceptionText;

/**
 `ATTRequestManager` is a wrapper for an HTTP client to request RESTful resources
 for AT&T's APIs.
 
 ## Methods to override
 
 To customize the parsing behavior you can override the method
 `parsedObjectForSuccessfulOperation:withResponse:forATTRequest:handleParsingErrorsWith:`
 
 @see IAMManager
 
@warning All requests are made using `JSON` as the transport format.
 */
@interface ATTRequestManager : NSObject

///---------------------------------------------
/// @name Accessing ATTRequestManager properties
///---------------------------------------------

/** The actual HTTP client to send the request */
@property (nonatomic, retain) AFHTTPClient* httpClient;

/**
 Configuration specific for this In-App Messaging client:
 * Application key and secret
 * Base URL
 * OAuth scopes
 */
@property (nonatomic, retain) ATTAppConfiguration* appConfig;

/**
 This will update the `Authorization` header for all requests.
 
 @warning Always use this property to update the token.
 */
@property (nonatomic,copy) OAuthToken* oauthToken;

/**
 Determines whether or not the token will be cached to the User Defaults
 for use in later launches of the application.
 Default value: YES
 */
@property (nonatomic) BOOL shouldCacheToken;

/** 
 The request manager's delegate will have to implement the @see`ATTOAuthConsent`
 protocol and will be able to receive messages about the status
 of the OAuth authentication process. 
 
 @see ATTOAuthConsent
 */
@property (nonatomic, weak) id<ATTOAuthConsent> delegate;

#pragma mark - Constructor

///-------------------------------------
/// @name Initializing a request manager
///-------------------------------------

/**
Initializes an `ATTRequestManager` with the details provided in `appConfig`
 and assigns the delegate for the OAuth consent flow.
 @param appConfig The application configuration for the current request manager.
 @param delegate The delegate for sending messages defined in the `ATTOAuthConsent`
 protocol.
 
 @see ATTOAuthConsent
 */
-(id)initWithConfig:(ATTAppConfiguration*)appConfig andDelegate:(id<ATTOAuthConsent>)delegate;

#pragma mark - Making Requests

///---------------------------------
/// @name Making requests to AT&T's APIs
///---------------------------------

/** 
Will send an asynchronous HTTP request constructed from `attRequest` and will 
 process the response using the `failure` and `success` blocks.
 
 @param attRequest An instance of `ATTRequest` that represents the HTTP request for the
resource that needs to be accessed.
 @param success A block that receives an `NSObject`. This object represents the JSON
 response obtained from the HTTP request.
 @param failure A block that receives an instance of `NSError`. This error contains
 the details of the failure and allow custom handling of errors.
 @see ATTRequest
 */
-(void)sendAsynchronous:(ATTRequest*)attRequest success:(void (^)(id))success
                failure:(void (^)(NSError*))failure;

/** 
 Creates NSObjects objects representing the JSON response for the HTTP request.
 It delegates the creation of the `NSObject`s to the `parseResponse:` 
 message of the specific `ATTRequest` being used.
 
 @param operation An instance of `AFHTTPOperation` that represents the `URLRequest`
 for the desired resource.
 
 @warning Only kept in the public interface to make it visible to sub-classes.
 
 */
-(id)parsedObjectForSuccessfulOperation:(AFHTTPRequestOperation *)operation
                           withResponse:(id)response
                          forATTRequest:(ATTRequest *)attRequest
                handleParsingErrorsWith:(void (^)(NSError *))failure;
@end

