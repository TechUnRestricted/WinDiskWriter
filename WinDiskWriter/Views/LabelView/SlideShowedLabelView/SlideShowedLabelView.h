//
//  SlideShowedLabelView.h
//  WinDiskWriter
//
//  Created by Macintosh on 05.12.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "LabelView.h"

NS_ASSUME_NONNULL_BEGIN

@interface SlideShowedLabelView : LabelView

@property (nonatomic, readwrite) BOOL isSlideShowed;
@property (nonatomic, readwrite) NSTimeInterval easeOutDuration NS_AVAILABLE(10.7, *);
@property (nonatomic, readwrite) NSTimeInterval easeInDuration NS_AVAILABLE(10.7, *);

@property (nonatomic, copy, readonly) NSArray<NSString *> *stringArray;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithStringArray: (NSArray<NSString *> *)stringArray
                      delayDuration: (NSTimeInterval)delayDuration;

- (void)setAnimatedStringValue: (NSString *)stringValue;

@end

NS_ASSUME_NONNULL_END
