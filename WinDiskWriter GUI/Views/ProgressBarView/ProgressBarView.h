//
//  ProgressBarView.h
//  WinDiskWriter GUI
//
//  Created by Macintosh on 16.08.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface ProgressBarView : NSProgressIndicator

- (void)setMaxValueSynchronously:(double)maxValue;

- (void)setMinValueSynchronously:(double)minValue;

- (void)incrementBySynchronously:(double)delta;

@end

NS_ASSUME_NONNULL_END
