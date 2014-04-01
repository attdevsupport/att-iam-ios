//
//  ViewController.h
//  InAppMessagingSampleApp
//
//  Created by Pablo Padilla on 1/15/14.
//  Copyright (c) 2014 AT&T. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IAMSendMessageRequest.h"
#import "AttachmentCell.h"
#import <AddressBookUI/AddressBookUI.h>

@protocol MessageComposerDelegate;

@interface MessageComposer : UIViewController<UICollectionViewDataSource,
UIImagePickerControllerDelegate, UINavigationControllerDelegate,
UITextViewDelegate, UITextFieldDelegate, UICollectionViewDelegate, AttachmentCellDelegate, ABPeoplePickerNavigationControllerDelegate>

@property (nonatomic, copy) NSString* addresses;

@property (retain, nonatomic) id<MessageComposerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITextField *addressesTextField;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UITextField *subjectTextField;
@property (weak, nonatomic) IBOutlet UIButton *addImageButton;
@property (weak, nonatomic) IBOutlet UICollectionView *attachmentsCollection;
@property (weak, nonatomic) IBOutlet UIButton *addContactButton;


@end

@protocol MessageComposerDelegate <NSObject>

-(void)messageComposer:(MessageComposer*)composer
           sentRequest:(IAMSendMessageRequest*)attRequest;

@end
