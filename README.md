# AT&T In-App Messaging (IAM) SDK for iOS


With the AT&T In-App Messaging API, your users can send & receive text
& media directly through your app to any mobile number in the U.S. 

The In-App Messaging SDK  is an iOS library for natively consuming the RESTful resources for [AT&T's In-App Messaging API](http://developer.att.com/apis/in-app-messaging). The SDK abstracts away all the networking tasks so that you can focus on what matters, getting & sending your messages. 

# Quick start

1. Open `InAppMessagingSampleApp.xcodeproj` 
2. Run the `InAppMessagingSampleAp` target.


# Overview

There are two main components to the library:

 - A set of request wrappers for the HTTP requests to access the API's resources.
 - A request manager --HTTP client-- to handle all your In-App Messaging requests.

## Request wrappers

The In-App Messaging SDK provides Objective-C wrappers for the actual [REST resources](http://developer.att.com/apis/in-app-messaging/docs#resources) you want to access in your application and exposes the main request parameters.

| NSObject subtype | 
| -------- | 
| `IAMCreateMessageIndexRequest` |
| `IAMMessageRequest` |
| `IAMMessagesListRequest` |
| `IAMSendMessageRequest` |
| `IAMDeleteMessageRequest` |
| `IAMDeleteMessagesRequest` |
| `IAMDeltasUpdateRequest` |
| `IAMMessageContentRequest` |
| `IAMMessageIndexInfoRequest` |
| `IAMNotificationConnectionRequest` |
| `IAMUpdateMessageRequest` |
| `IAMUpdateMessagesRequest` |


## Request management

AT&T's In-App Messaging SDK abstracts away the networking layer by providing a request manger: `IAMManager`, think of it as an HTTP client, it creates the actual HTTP requests using an instance of `ATTRequest` or any of it's sub-classes (see previous section) and allows the developer to define the success and failure callbacks. This way you can access the API resources with a simple call:

```objc    
    // Make the request
    [iamManager sendAsynchronous:iamRequest success:^(id requestResponse) {
        // your code for success 
    } failure:^(NSError *error) {
        // your code for failure
    }];
```

[See more usage examples](#usage)

# Using the In-App Messaging SDK in your App


1. Add the files under `InAppMessaging` to your project
2. Link with the static library `libInAppMessaging-.a` in your *Build Phases*

## Usage

### Create an In-App Messaging client

```objc
    // initialize the app configuration
    ATTAppConfiguration* _appConfig= [[ATTAppConfiguration alloc] init];
    _appConfig.key= AppKey;
    _appConfig.secret= AppSecret;
    _appConfig.scope= AppScope;
    _appConfig.baseURL= [NSURL URLWithString:APIBaseURL];
    _appConfig.redirectURL= [NSURL URLWithString:RedirectURL];
    
    // initialize a client for In-App Messaging
    IAMManager* messagingManager= [[IAMManager alloc] initWithConfig:_appConfig andDelegate:nil];
```

### Send an SMS

```objc
	// Send an SMS message
    [messagingManager sendSMS:@"This is a test message"
                           to:@"tel:1234567890,someone@somewhere.com"
                      failure:^(NSError* error){
                          NSLog(@"%@", error.localizedDescription);
                      }];
```

### Send an MMS

```objc
	IAMSendMessageRequest* sendRequest= [[IAMSendMessageRequest alloc] init];
    sendRequest.addresses= @[@"tel:1231231230", @"someone@somewhere.com"];
    sendRequest.text= @"Hellou!";
    sendRequest.subject= @"Hi, this is an MMS message";
    
    // ADD an image to the message
    [sendRequest addImage:[UIImage imageNamed:@"image"]];
    
    [messagingManager sendAsynchronous:sendRequest success:^(id messageId) {
        NSLog(@"Succesfully sent message with Id: %@", messageId);
    } failure:^(NSError *error) {
        NSLog(@"%@", error.localizedDescription);
    }];
```
