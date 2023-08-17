//
//  ProgressBarView.m
//  WinDiskWriter GUI
//
//  Created by Macintosh on 16.08.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "ProgressBarView.h"

@implementation ProgressBarView

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

- (void)incrementBySynchronously:(double)delta {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self incrementBy:delta];
    });
}

- (void)resetProgress {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setDoubleValue: 0.0];
        
        [self setMinValue: 0.0];
        [self setMaxValue: 100.0];
    });
}

@end
