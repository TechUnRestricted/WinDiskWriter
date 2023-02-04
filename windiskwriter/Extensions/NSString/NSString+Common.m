//
//  NSString+Common.m
//  windiskwriter
//
//  Created by Macintosh on 27.01.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "NSString+Common.h"

@implementation NSString (Common)

- (BOOL)hasOneOfThePrefixes: (NSArray *)prefixes {
    for (NSString *prefix in prefixes) {
        if ([self hasPrefix:prefix]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)hasOneOfTheSuffixes: (NSArray *)suffixes {
    for (NSString *suffix in suffixes) {
        if ([self hasSuffix:suffix]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isOneOfTheValues: (NSArray *)values {
    for (NSString *value in values) {
        if (self == value) {
            return YES;
        }
    }
    return NO;
}

@end
