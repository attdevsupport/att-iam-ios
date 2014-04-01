//
//  ContactConvertor.m
//  InAppMessagingSampleApp
//
//  Created by John O'Dowd on 1/30/14.
//  Copyright (c) 2014 AT&T. All rights reserved.
//

#import "ContactConvertor.h"
#import "Utils.h"
#import <AddressBook/AddressBook.h>
#import "Utils.h"

@implementation ContactConvertor


+(NSDictionary *)contactNamesForNumbers:(NSArray *)numbers{
    // get all the contacts
    NSDictionary *allContacts = [ContactConvertor getContactDictionary];
    
    NSMutableDictionary *nameAndNumber = [NSMutableDictionary dictionary];

    // for each contact in the dictionary
    for (NSString *name in allContacts) {
        
        // get all numbers for current contact
        NSArray* numbersForName = allContacts[name];
        
        // if the input number matches a contact in the contactsDictionary
        // add it to the nameAndNumber dictionary
        for (NSString* inputNo in numbers) {
            if ([numbersForName containsObject:inputNo]) {
                // add to the dictionary
                (nameAndNumber)[inputNo]= name;
            }
        }
    }

    return nameAndNumber? nameAndNumber: nil;
}

// returns a dictionary with the full names of the contacts
// as keys and the array of his phone numbers as the values
+( NSDictionary *)getContactDictionary{
    
    CFErrorRef *error = NULL;
    // the the addressbook
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
    // try to get the access to the addressbook
    BOOL accessGranted = [ContactConvertor addressBookAccessStatus:addressBook];
    
    // TODO: is this __autoreleasing really necessary?
    __autoreleasing NSMutableDictionary *contactsDictionary = [NSMutableDictionary dictionary];
    
    // if we have access
    if (accessGranted){
        // copy all the contact records and transfer ownership
        NSArray * people= (__bridge_transfer NSArray*)ABAddressBookCopyArrayOfAllPeople(addressBook);
        
        // add each person's full name and numbers to the contacts dictionary
        for(id person in people){
            // fetch all the numbers for the current person
            ABMultiValueRef allNumbers = ABRecordCopyValue((__bridge ABRecordRef)(person), kABPersonPhoneProperty);
            
            // add all the numbers for the current person to an NSArray
            NSMutableArray *personNos = [NSMutableArray array];
            // for each number
            for (CFIndex j=0; j < ABMultiValueGetCount(allNumbers); j++) {
                // add the number to the current person numbers array
                NSString* phone = (NSString*)CFBridgingRelease(ABMultiValueCopyValueAtIndex(allNumbers, j));
                [personNos addObject:[Utils removeFormattingForNumber:phone]];
            }
            // add the current person & his numbers to the contacts dictionary
            NSString *fullName = (__bridge NSString *)ABRecordCopyCompositeName((__bridge ABRecordRef)(person));
            // add only it we get a valid name and the name has numbers
            if (fullName && 0<[personNos count]) {
                (contactsDictionary)[fullName]= personNos;
            }
        }
        
    }
    return contactsDictionary;
}

// returns the access status for the adressbook
+(BOOL)addressBookAccessStatus:(ABAddressBookRef) addressBook{
    __block BOOL accessGranted = NO;
    
    // create a semaphore to receive the access status signal
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    
    // request access to the addresbook,
    // blocks the thread until you get access
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
        accessGranted = granted;
        // send the signal to unblock the thread
        dispatch_semaphore_signal(sema);
    });
    // wait until you recieve the signal for this semaphore
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
   return accessGranted;
}
@end
