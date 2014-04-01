//
//  Utils.m
//  InAppMessagingSampleApp
//
//  Created by Pablo Padilla on 1/30/14.
//  Copyright (c) 2014 AT&T. All rights reserved.
//

#import "Utils.h"

@implementation Utils

+(NSString*)removeFormattingForNumber:(NSString*)value{
    
    NSMutableCharacterSet* set= [[NSMutableCharacterSet alloc] init];
    [set addCharactersInString:@"() - "];
    // remove all formatting characters from the number
    value= [[value componentsSeparatedByCharactersInSet:set] componentsJoinedByString:@""];
    
    return value;
}

+(NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSDayCalendarUnit
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}

+(NSString*)formatDateForLabel:(NSDate*)date{
    
    NSString* dateString= nil;
    NSDateFormatter* df= [[NSDateFormatter alloc] init];
    NSString* todayFormat= @"hh:mm a";
    NSString* fullDateFormat= @"MM/dd/yyyy";
    
    NSTimeZone *localTimeZone = [NSTimeZone localTimeZone];
    NSTimeZone *utcTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    
    NSInteger localOffset = [localTimeZone secondsFromGMTForDate:date];
    NSInteger utcOffset = [utcTimeZone secondsFromGMTForDate:date];
    NSTimeInterval differnceBetweenLocalAndUTC = localOffset - utcOffset;
    
    NSDate *localDate = [[NSDate alloc] initWithTimeInterval:differnceBetweenLocalAndUTC sinceDate:date];
    
    // if it's today's date
    if (1>[Utils daysBetweenDate:localDate andDate:[NSDate date]]) {
        // use the short format: `11:34 PM`
        df.dateFormat= todayFormat;
        dateString= [df stringFromDate:localDate];
    }else {// use full date format for older dates: `MM/dd/yyyy`
        df.dateFormat= fullDateFormat;
        dateString= [df stringFromDate:localDate];
    }

    return dateString;
}

@end
