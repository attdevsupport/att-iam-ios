//
//  TextViewController.h
//  InAppMessagingSampleApp
//
//  Created by John O'Dowd on 1/28/14.
//  Copyright (c) 2014 AT&T. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextViewController : UIViewController
@property (nonatomic, strong) NSString *text;
@property (nonatomic, weak) IBOutlet UITextView *textView;
@end
