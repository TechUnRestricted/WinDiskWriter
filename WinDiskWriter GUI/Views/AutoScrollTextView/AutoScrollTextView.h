//
//  AutoScrollTextView.h
//  WinDiskWriter GUI
//
//  Created by Macintosh on 10.08.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface AutoScrollTextView : NSScrollView

@property (nonatomic, strong, readonly) NSTextView *textViewInstance;

- (void)appendLine:(NSString *)message;

- (void)appendTimestampedLine: (NSString *)message;

- (void)clear;

@end

NS_ASSUME_NONNULL_END
