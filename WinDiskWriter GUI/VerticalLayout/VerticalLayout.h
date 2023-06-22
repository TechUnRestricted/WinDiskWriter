//
//  VerticalLayout.h
//  WinDiskWriter GUI
//
//  Created by Macintosh on 14.06.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface VerticalLayout : NSView

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
