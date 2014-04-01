//
//  ContactConvertor.h
//  InAppMessagingSampleApp
//
//  Created by John O'Dowd on 1/30/14.
//  Copyright (c) 2014 AT&T. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContactConvertor : NSObject
+(NSDictionary *)contactNamesForNumbers:(NSArray *)phoneNumbers;
@end
