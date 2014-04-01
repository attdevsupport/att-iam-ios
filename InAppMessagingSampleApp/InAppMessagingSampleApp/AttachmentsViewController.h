//
//  AttachmentsViewController.h
//  InAppMessagingSampleApp
//
//  Created by John O'Dowd on 1/28/14.
//  Copyright (c) 2014 AT&T. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IAMManager;
@class IAMMessage;

@interface AttachmentsViewController : UIViewController
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) IAMManager *iamManager;
@property (nonatomic, strong) IAMMessage *message;
@property (nonatomic, assign) NSInteger tempCountOfImages;
@property (nonatomic, assign) NSInteger tempCountOfTextFiles;
@end
