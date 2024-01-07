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
    NSString *localizedDescriptionKey = [self.userInfo objectForKey: NSLocalizedDescriptionKey];
    
    if (localizedDescriptionKey != NULL) {
        return localizedDescriptionKey;
    }
    
    return self.localizedDescription;
}

+ (NSError *)errorWithStringValue: (NSString *)stringValue {    
    return [NSError errorWithDomain: [Constants bundleIndentifier]
                               code: -1
                           userInfo: @{NSLocalizedDescriptionKey: stringValue}];
}

@end
