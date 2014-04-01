//
//  ViewController.m
//  InAppMessagingSampleApp
//
//  Created by Pablo Padilla on 1/15/14.
//  Copyright (c) 2014 AT&T. All rights reserved.
//

#import "MessageComposer.h"
#import "AttachmentCell.h"
#import <AddressBookUI/AddressBookUI.h>
#import "Utils.h"

@interface MessageComposer ()

@end

@implementation MessageComposer
{
    NSMutableArray* _attachments;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // set the default value for the addresses field
    _addressesTextField.text= _addresses;
    
    _attachmentsCollection.delegate= self;
    [_attachmentsCollection registerClass:[AttachmentCell class]
               forCellWithReuseIdentifier:@"Cell"];
    
    _attachments= [NSMutableArray array];
    
    [_addContactButton setImage:[UIImage imageNamed:@"addContact"] forState:UIControlStateHighlighted];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UICollectionDataSource

-(NSInteger)collectionView:(UICollectionView *)collectionView
    numberOfItemsInSection:(NSInteger)section{

    return _attachments.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath{

    AttachmentCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell"
                                                                           forIndexPath:indexPath];
    cell.delegate= self;
    [cell.imageView setImage:_attachments[indexPath.row]];

    return cell;
}


#pragma mark - Events

- (IBAction)addImage:(id)sender {
    
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    
    // Displays saved pictures and movies, if both are available, from the
    // Camera Roll album.
    mediaUI.mediaTypes =
    [UIImagePickerController availableMediaTypesForSourceType:
     UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    mediaUI.allowsEditing = NO;
    
    mediaUI.delegate = self;
    
    [self presentViewController:mediaUI animated:YES completion:nil];
}

- (IBAction)sendMessage:(id)sender {
    
    IAMSendMessageRequest* sendRequest= [[IAMSendMessageRequest alloc] init];
    
    NSMutableArray* addresses= [NSMutableArray arrayWithArray:
                                [_addressesTextField.text componentsSeparatedByString:@","]];
    
    for (int i=0; i<addresses.count; ++i) {
        NSString* curAddress= addresses[i];
        
        if ([curAddress isEqualToString:@""]) {
            //ignore emtpy strings
            continue;
        }
        
        NSRange telRange= [curAddress rangeOfString:@"tel:" options:NSCaseInsensitiveSearch];
        NSRange atRange= [curAddress rangeOfString:@"@" options:NSCaseInsensitiveSearch];
        
        if ( NSNotFound == atRange.location // it is not an email address
            // does NOT contain `tel:` but it's a phone number
            && NSNotFound == telRange.location && curAddress.length>=10 ) {
            // update the address with the `tel:` prefix
            addresses[i]= [NSString stringWithFormat:@"tel:%@", curAddress];
        }
    }
    // update the addresses
    sendRequest.addresses= addresses;
    
    // if there are attachments
    if (_attachments.count>0) {
        sendRequest.subject= _subjectTextField.text;
        
        for (UIImage* curImage in _attachments) {
            [sendRequest addImage:curImage];
        }
    }else{
        sendRequest.text= _messageTextView.text;
    }
    
    [_delegate messageComposer:self sentRequest:sendRequest];
}

#pragma mark - UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
    UIImage* image= (info)[UIImagePickerControllerOriginalImage];
    [_attachments addObject:image];
    [_attachmentsCollection reloadData];
    
    [_subjectTextField setEnabled:YES];
    [_subjectTextField becomeFirstResponder];

}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{

    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UITextViewDelegate

- (BOOL) textView:(UITextView*)textView shouldChangeTextInRange:(NSRange)range
  replacementText: (NSString*) text{
    
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
    
}

#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - AttachmentCellDelegate
-(void)removeCell:(AttachmentCell *)cell{
    // remove the image corresponding to this cell from the array
    [_attachments removeObject:cell.imageView.image];
    
    [_attachmentsCollection reloadData];
}

#pragma mark - Contacts

- (IBAction)pickContact:(id)sender {

    // show the default people picker
    ABPeoplePickerNavigationController* contactPicker=
    [[ABPeoplePickerNavigationController alloc] init];
    contactPicker.peoplePickerDelegate= self;
    
    [self presentViewController:contactPicker animated:YES completion:nil];
    
}

#pragma mark - ABPeoplePickerNavigationController
-(void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker{
    // hide people picker on cancel
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
     shouldContinueAfterSelectingPerson:(ABRecordRef)person{
    return YES;
}

-(BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
     shouldContinueAfterSelectingPerson:(ABRecordRef)person
                               property:(ABPropertyID)property
                             identifier:(ABMultiValueIdentifier)identifier{

    // Get the name of the selected contact
    NSString* name = (__bridge_transfer NSString*)ABRecordCopyValue(person,
                                                                    kABPersonFirstNameProperty);
    
    NSString* value;
    // get the list of entries for the given property (email addresses, phone numbers, etc)
    ABMultiValueRef entries= ABRecordCopyValue(person, property);
    if (ABMultiValueGetCount(entries) > 0) {
        // get the value of the selected entry
        value = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(entries, identifier);
    }
    
    value= [Utils removeFormattingForNumber:value];
    
    NSLog(@"%@ - %@", name, value);
    
    // add the number to the addresses field
    if (0==_addressesTextField.text.length) {
        _addressesTextField.text= value;
    }else{
        // append the value at the end
        _addressesTextField.text= [_addressesTextField.text stringByAppendingString:
                                   [NSString stringWithFormat:@",%@",value]];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // don't use the default action for this selection
    return NO;
}


@end
