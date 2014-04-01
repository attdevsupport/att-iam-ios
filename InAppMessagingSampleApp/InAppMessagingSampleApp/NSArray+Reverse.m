//
//  NSMutableArray+Reverse.m
//  InAppMessagingSampleApp
//
//  Created by Pablo Padilla on 2/6/14.
//  Copyright (c) 2014 AT&T. All rights reserved.
//

#import "NSArray+Reverse.h"

@implementation NSArray (Reverse)

- (NSArray *)reversedArray {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[self count]];
    NSEnumerator *enumerator = [self reverseObjectEnumerator];
    for (id element in enumerator) {
        [array addObject:element];
    }
    return array;
}

@end
