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

#import <UIKit/UIKit.h>
#import "ATTRequestManager.h"
#import "OAuthToken.h"

/** 
`ATTOAuthViewController` is a simple view controller to present the AT&T
 authorization page to provision an application to send messages on behalf of 
 an AT&T number.
 
 @discussion It basically presents a `UIWebView` with the URL specified in the 
 application configuration and handles the events generated in that view.
 
 * If the user authorizes the application, it sends the `didGetToken:` message 
 using the `ATTOAuthConsent` protocol to it's delegate.
 * If the user cancels, or the token request fails, it sends the `didFailToGetToken:`
 message to its delegate.
 
  @see ATTOAuthConsent
 */
@interface ATTOAuthViewController : UIViewController<UIWebViewDelegate>

/** The delegate must implement the `ATTOAuthConsent` protocol
    It will handle message for succeeding/failing when getting the Access Token.
 
 @see ATTOAuthConsent
 */
@property (nonatomic, weak) id<ATTOAuthConsent> delegate;

/** Setup the URL and keys for getting the access code and access token 
 
 @param appConfig The configuration for this application.
    @warning Must be called before trying to present the view controller, otherwise
    the webView will load the default URL: [AT&T](https://att.com)
 
 @see ATTAppConfiguration
 */
-(void)setConfiguration:(ATTAppConfiguration*)appConfig;

@end
