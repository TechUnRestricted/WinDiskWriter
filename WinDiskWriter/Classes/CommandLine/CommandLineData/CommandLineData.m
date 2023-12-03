//
//  CommandLineData.m
//  WinDiskWriter GUI
//
//  Created by Macintosh on 25.11.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "CommandLineData.h"

@implementation CommandLineData

- (instancetype)initWithProcessIdentifier: (NSInteger)processIdentifier
                        terminationStatus: (NSInteger)terminationStatus
                        terminationReason: (NSTaskTerminationReason)terminationReason
                             standardData: (NSData *)standardData
                                errorData: (NSData *)errorData {
    self = [super init];
    
    _processIdentifier = processIdentifier;
    _terminationStatus = terminationStatus;
    _terminationReason = terminationReason;
    _standardData = standardData;
    _errorData = errorData;
    
    return self;
}

@end
