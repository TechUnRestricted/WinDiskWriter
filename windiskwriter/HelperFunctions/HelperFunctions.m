//
//  HelperFunctions.m
//  windiskwriter
//
//  Created by Macintosh on 27.01.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "HelperFunctions.h"
#import <unistd.h>

@implementation HelperFunctions

+ (BOOL) hasElevatedRights {
    return getuid() == 0;
}

@end
