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

extern NSString* const OAuthAuthorizationPath;
extern NSString* const OAuthTokenPath;

@class OAuthToken, ATTAppConfiguration;

/**
 If implemented the `ATTOAuthConsent` protocol must be used to notify
 about the need to present the authorization page to the user, and about 
 success or failure to obtain the access token.
 */
@protocol ATTOAuthConsent <NSObject>

///---
/// @name Requesting the authorization page
/// ---
/**
 Notifies that the OAuth authorization page should be represented.
 
@discussion The authorization page is a webpage where the user provides 
access for this application to use his/her device with AT&T's APIs. 
 
 There are three scenarios where this is necessary:
 
 * Initial authorization
 * Invalid or Expired token and invalid refresh token
 * The token in cache has been cleared

 */
@optional
-(void)showAuthorizationPage;

///---
/// @name Processing the token
/// ---
/** 
 Notifies about the new token obtained.
 
 @discussion This gets called when the user allows the application
 in the authorization page.
 
 @param token The new OAuth token to be used as a header for all 
 subsequent HTTP requests.
 */
-(void)didGetToken:(OAuthToken*)token;

/// @name Cancelling the authorization dialog
/// ---
/**
 Notifies when the user cancels the authorization dialog.
 
 @discussion This gets called when the user cancels the authorization page.
 
 */
-(void)didCancel;

///---
/// @name Reporting failed token request
/// ---

/** 
 Notifies that there was an error trying to get a token from the 
 authorization page.
 */
-(void)didFailToObtainToken:(NSError*)error;


@end


/** 
 `ATTOAuthClient` Implements an HTTP client for the OAuth API defined in:
 [OAuth 2.0 API](http://developer.att.com/apis/oauth-2/docs/v1)
 */
@interface ATTOAuthClient : NSObject

// TODO: add init with default appConfig values

///------------------------------------
/// @name Initializing the OAuth client
///------------------------------------

/** Creates an HTTP client for AT&T's OAuth authorization methods.
 @param appConfig The configuration to create the request: key, secret
 base URL and scope.
 
 @see ATTAppConfiguration
 */
-(id)initWithAppConfig:(ATTAppConfiguration*)appConfig;


#pragma mark - Getting the Access Token
///------------------------------------
/// @name Getting an Access Token
///------------------------------------

/** Wrapper for getting an `OAuthToken` using only the client application
 credentials. 
 
 @param success A block that processes the `OAuthToken` obtained.
 @param failure A block to process the `NSError` generated during the request.
 
 @warning This works only for non-User-Consent-based APIs (scopes), i.e.,
 `ADS,MMS,SMS`
 */
-(void)getTokenWithSuccessBlock:(void (^)(OAuthToken*))success
                        failure:(void (^)(NSError*))failure;

/** Wrapper for getting an Access Token using an authorization code.
 
 @param code The authorization code obtained from the browser after the user
 authorizes the application.
 @param success A block that processes the `OAuthToken` obtained.
 @param failure A block to process the `NSError` generated during the request.
 
 @warning This works only for User-Consent-based APIs (scopes), i.e.,
 `DC,MIM,IMMN`
 
 */
-(void)getTokenWithCode:(NSString*)code
                success:(void (^)(OAuthToken*))success
                failure:(void (^)(NSError*))failure;

/** Wrapper for getting an Access Token using a valid Refresh Token
 
 @param refreshToken A refresh token from a previous `OAuthToken`
 @param success A block that processes the `OAuthToken` obtained.
 @param failure A block to process the `NSError` generated during the request.
 
 */
-(void)getTokenWithRefreshToken:(NSString*)refreshToken
                        success:(void (^)(OAuthToken*))success
                        failure:(void (^)(NSError*))failure;

#pragma mark - Persisting credentials

///------------------------------------
/// @name Persisting the credentials to the Keychain
///------------------------------------

/** Saves the current credentials to the Keychain */
-(void)saveCredentialsToKeychain;
/** Retrieves the current credentials from the Keychain */
-(NSURLCredential*)currentCredentials;

#pragma mark - Persisting the Token

///------------------------------------
/// @name Persisting the token to the User Defaults
///------------------------------------

/** Persists the current `OAuthToken` to the User Defaults */
+(void)cacheToken:(OAuthToken*)token;
/** Retrieves the current `OAuthToken` from the User Defaults */
+(OAuthToken*)getCachedToken;
/** Removes the current `OAuthToken` to the User Defaults */
+(void)clearCachedToken;

@end
