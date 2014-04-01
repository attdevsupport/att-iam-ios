//
//  AppDelegate.m
//  InAppMessagingSampleApp
//
//  Created by Pablo Padilla on 1/15/14.
//  Copyright (c) 2014 AT&T. All rights reserved.
//

#import "AppDelegate.h"
#import "ATTAppConfiguration.h"
#import "OAuthToken.h"
#import "IAMManager.h"

@implementation AppDelegate

/** These are our assumptions for running the Sample App:
 - You have joined the AT&T Developer program at: http://developer.att.com/
 - You have created an App under your AT&T Developer program account
 - You have OAuth credentials for your Application. (AppKey, AppSecret)
 - You have enabled the In-App Messaging API's in your app. (MIM & IMMN scopes)
 - You have a basic understanding of the resources you want to use:
 https://developer.att.com/apis/in-app-messaging/docs#resources
 */

NSString* const APIBaseURL=@"https://api.att.com";
NSString* const RedirectURL= @"http://localhost";
/** NOTE ON SECURITY **
 * Please use proper security in you app to safeguard your client credentials.
 * You can save your credentials to the KeyChain by using the built-in method:
 * `[ATTOAuthClient saveCredentialsToKeyChain]`
 */
NSString* const AppKey= @APP_KEY;
NSString* const AppSecret= @APP_SECRET;
NSString* const AppScope= @"MIM,IMMN";

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    // initialize the app configuration
    self.appConfig= [[ATTAppConfiguration alloc] init];
    self.appConfig.key= AppKey;
    self.appConfig.secret= AppSecret;
    self.appConfig.scope= AppScope;
    self.appConfig.baseURL= [NSURL URLWithString:APIBaseURL];
    self.appConfig.redirectURL= [NSURL URLWithString:RedirectURL];

    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
