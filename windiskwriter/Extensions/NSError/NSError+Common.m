//
//  NSError+Common.m
//  windiskwriter
//
//  Created by Macintosh on 20.08.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "NSError+Common.h"

@implementation NSError (Common)

- (NSString *)stringValue {
    return [self.userInfo objectForKey: NSLocalizedDescriptionKey];
}

@end
