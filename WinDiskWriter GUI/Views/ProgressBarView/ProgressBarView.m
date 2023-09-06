//
//  ProgressBarView.m
//  WinDiskWriter GUI
//
//  Created by Macintosh on 16.08.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "ProgressBarView.h"

@implementation ProgressBarView

- (instancetype)init {
    self = [super init];
    
    [self setIndeterminate: NO];
    
    [self resetProgressSynchronously];
    
    return self;
}

- (void)setMaxValueSynchronously:(double)maxValue {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setMaxValue:maxValue];
    });
}

- (void)setMinValueSynchronously:(double)minValue {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setMinValue:minValue];
    });
}

- (void)setDoubleValueSynchronously:(double)doubleValue {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setDoubleValue:doubleValue];
    });
}

- (void)incrementBySynchronously:(double)delta {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self incrementBy:delta];
    });
}

- (void)resetProgressSynchronously {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setDoubleValue: 0.0];
        [self setMinValue: 0];
        [self setMaxValue: FLT_MAX];
    });
}

@end
