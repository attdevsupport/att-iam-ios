//
//  ImageCollectionViewCell.h
//  InAppMessagingSampleApp
//
//  Created by Pablo Padilla on 1/16/14.
//  Copyright (c) 2014 AT&T. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AttachmentCellDelegate<NSObject>

-(void)removeCell:(UICollectionViewCell*)cell;

@end

@interface AttachmentCell : UICollectionViewCell<UIGestureRecognizerDelegate>

@property (retain, nonatomic) id<AttachmentCellDelegate> delegate;
@property (retain, nonatomic) UIImageView* imageView;

@end
