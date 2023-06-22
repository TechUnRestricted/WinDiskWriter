//
//  LayoutElement.h
//  WinDiskWriter GUI
//
//  Created by Macintosh on 14.06.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface LayoutElement : NSObject

@property (nonatomic, readonly, strong) NSView *nsView;

@property (nonatomic, readwrite) CGFloat minHeight;
@property (nonatomic, readwrite) CGFloat maxHeight;

@property (nonatomic, readwrite) CGFloat minWidth;
@property (nonatomic, readwrite) CGFloat maxWidth;

@property (nonatomic, readwrite) CGFloat computedSize;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithNSView: (NSView * _Nonnull)nsView;

/*
- (instancetype)initWithMinWidth: (CGFloat)minWidth
                        maxWidth: (CGFloat)maxWidth
                       minHeight: (CGFloat)minHeight
                       maxHeight: (CGFloat)maxHeight;

- (instancetype)initWithWidth: (CGFloat)width
                       height: (CGFloat)height;
*/


@end

NS_ASSUME_NONNULL_END
