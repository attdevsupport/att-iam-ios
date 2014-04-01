//
//  Utils.h
//  InAppMessagingSampleApp
//
//  Created by Pablo Padilla on 1/30/14.
//  Copyright (c) 2014 AT&T. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utils : NSObject

+(NSString*)removeFormattingForNumber:(NSString*)value;
+(NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime;
+(NSString*)formatDateForLabel:(NSDate*)date;
@end
