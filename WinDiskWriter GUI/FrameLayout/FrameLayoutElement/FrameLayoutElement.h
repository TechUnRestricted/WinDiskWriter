//
//  FrameLayoutElement.h
//  WinDiskWriter GUI
//
//  Created by Macintosh on 14.06.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface FrameLayoutElement : NSObject

@property (nonatomic, readonly, strong) NSView *nsView;

@property (nonatomic, readwrite) CGFloat minHeight;
@property (nonatomic, readwrite) CGFloat maxHeight;

@property (nonatomic, readwrite) CGFloat minWidth;
@property (nonatomic, readwrite) CGFloat maxWidth;

@property (nonatomic, readwrite) CGFloat computedWidth;
@property (nonatomic, readwrite) CGFloat computedHeight;

@property (nonatomic, readwrite) CGFloat paddingTop;
@property (nonatomic, readwrite) CGFloat paddingBottom;

@property (nonatomic, readwrite) CGFloat paddingLeft;
@property (nonatomic, readwrite) CGFloat paddingRight;

- (void)setPaddingTop: (CGFloat)paddingTop
        paddingBottom: (CGFloat)paddingBottom
          paddingLeft: (CGFloat)paddingLeft
         paddingRight: (CGFloat)paddingRight;

- (CGFloat)canvasWidth;

- (CGFloat)nsViewWidth;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithNSView: (NSView *)nsView;

@end

NS_ASSUME_NONNULL_END
