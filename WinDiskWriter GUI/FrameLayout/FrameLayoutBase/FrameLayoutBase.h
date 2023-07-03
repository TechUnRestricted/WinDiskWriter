//
//  FrameLayoutBase.h
//  WinDiskWriter GUI
//
//  Created by Macintosh on 14.06.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FrameLayoutElement.h"

typedef NS_ENUM(NSUInteger, FrameLayoutVerticalAlignment) {
    FrameLayoutVerticalTop,
    FrameLayoutVerticalBottom,
    FrameLayoutVerticalCenter
};

NS_ASSUME_NONNULL_BEGIN

@interface FrameLayoutBase : NSView

@property (nonatomic, readwrite) CGFloat spacing;
@property (nonatomic, readwrite) FrameLayoutVerticalAlignment verticalAlignment;

@property (nonatomic, strong) NSMutableArray<FrameLayoutElement *> *layoutElementsArray;
@property (nonatomic, strong) NSMutableArray<FrameLayoutElement *> *sortedElementsArray;

- (void)addView: (NSView * _Nonnull)nsView;

- (void)addView: (NSView * _Nonnull)nsView
       minWidth: (CGFloat)minWidth
       maxWidth: (CGFloat)maxWidth
      minHeight: (CGFloat)minHeight
      maxHeight: (CGFloat)maxHeight;

- (void)addView: (NSView * _Nonnull)nsView
          width: (CGFloat)width
         height: (CGFloat)height;

@end

NS_ASSUME_NONNULL_END
