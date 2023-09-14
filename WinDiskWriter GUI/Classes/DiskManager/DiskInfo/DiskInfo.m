//
//  DiskInfo.m
//  windiskwriter
//
//  Created by Macintosh on 07.09.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "DiskInfo.h"

@implementation DiskInfo

- (NSDate *_Nullable)appearanceNSDate {
    if (self.appearanceTime == NULL) {
        return NULL;
    }
    
    double appearanceDoubleValue = [self.appearanceTime doubleValue];
    
    NSDate *dateConverted = [NSDate dateWithTimeIntervalSinceReferenceDate: appearanceDoubleValue];
    
    return dateConverted;
}

@end
