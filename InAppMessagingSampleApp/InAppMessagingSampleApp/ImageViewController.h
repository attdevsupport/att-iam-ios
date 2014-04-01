//
//  ImageViewController.h
//  InAppMessagingSampleApp
//
//  Created by John O'Dowd on 1/28/14.
//  Copyright (c) 2014 AT&T. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageViewController : UIViewController
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@end
