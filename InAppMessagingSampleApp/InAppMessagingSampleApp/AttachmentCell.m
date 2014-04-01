//
//  AttachmentCell.m
//  InAppMessagingSampleApp
//
//  Created by John O'Dowd on 1/29/14.
//  Copyright (c) 2014 AT&T. All rights reserved.
//

#import "AttachmentCell.h"

@implementation AttachmentCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    
    // setup the image view
    _imageView= [[UIImageView alloc] initWithFrame:
                 CGRectMake(0, 0, frame.size.width, frame.size.height)];
    _imageView.contentMode= UIViewContentModeScaleAspectFit;
    _imageView.clipsToBounds= YES;
    [self addSubview:_imageView];

    // enable Long Press event on this view.
    UILongPressGestureRecognizer* longPress=[[UILongPressGestureRecognizer alloc]
                                             initWithTarget:self action:@selector(handleLongPress:)];
    longPress.delegate= self;
    [self addGestureRecognizer:longPress];
    
    return self;
}


#pragma mark - Deleting the Attachment Cell
-(void)handleLongPress:(UILongPressGestureRecognizer*)gr{
    
    if (gr.state != UIGestureRecognizerStateEnded) {
        return;
    }
    
    [self showMenu];
}

-(void)showMenu{
    // setup the view to show the UIMenuController
    [self becomeFirstResponder];
    
    UIMenuController* menuCtrl= [UIMenuController sharedMenuController];
    // position the menu
    [menuCtrl setTargetRect:self.frame inView:self];
    // show the menu immediately
    [menuCtrl setMenuVisible:YES animated:YES];
}



// this will be called when the user taps the Delete option in the
// Edit Menu for this Attachment Cell
-(void)delete:(id)sender{
    [self.delegate removeCell:self];
}

// must implement to show the UIMenuController
-(BOOL)canBecomeFirstResponder{
    return YES;
}

// must implement to show the UIMenuController
-(BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    
    // only show the delete action
    if (action == @selector(delete:)) {
        return YES;
    }
    // hide all other actions
    return NO;
}


@end



