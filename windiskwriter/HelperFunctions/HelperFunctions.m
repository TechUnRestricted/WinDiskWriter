//
//  HelperFunctions.m
//  windiskwriter
//
//  Created by Macintosh on 27.01.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "HelperFunctions.h"

@implementation HelperFunctions

+ (BOOL) hasElevatedRights {
    return getuid() == 0;
}

NSString *MSDOSCompliantSymbols  = @"ABCDEFGHIJKLMNOPQRSTUVWXZY0123456789";

+ (NSString *)randomStringWithLength: (uint64_t)requiredLength {
    NSMutableString *generatedString = [NSMutableString stringWithCapacity:requiredLength];
    for (NSUInteger i = 0U; i < requiredLength; i++) {
        u_int32_t r = arc4random() % [MSDOSCompliantSymbols length];
        unichar c = [MSDOSCompliantSymbols characterAtIndex:r];
        [generatedString appendFormat:@"%C", c];
    }
    
    return generatedString;
}

@end
