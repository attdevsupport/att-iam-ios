//
//  AppDelegate.h
//  InAppMessagingSampleApp
//
//  Created by Pablo Padilla on 1/15/14.
//  Copyright (c) 2014 AT&T. All rights reserved.
//

#import <UIKit/UIKit.h>
@class OAuthToken;
@class ATTAppConfiguration;
@class IAMManager;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) OAuthToken *token;
@property (strong, nonatomic) ATTAppConfiguration *appConfig;
@property (strong, nonatomic) IAMManager *iamManager;
@end
