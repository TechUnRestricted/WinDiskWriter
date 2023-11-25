//
//  NSError+Common.m
//  windiskwriter
//
//  Created by Macintosh on 20.08.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "NSError+Common.h"
#import "Constants.h"

@implementation NSError (Common)

- (NSString *)stringValue {
    return [self.userInfo objectForKey: NSLocalizedDescriptionKey];
}

+ (NSError *)errorWithStringValue: (NSString *)stringValue {
    return [NSError errorWithDomain: PACKAGE_NAME
                               code: -1
                           userInfo: @{NSLocalizedDescriptionKey: stringValue}];
}

@end
