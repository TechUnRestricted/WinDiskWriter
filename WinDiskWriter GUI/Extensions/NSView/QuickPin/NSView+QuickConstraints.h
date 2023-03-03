//
//  NSView+QuickConstraints.h
//  WinDiskWriter GUI
//
//  Created by Macintosh on 26.02.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSView (QuickConstraints)

- (void)setQuickPinWithLayoutAttribute: (NSLayoutAttribute)layoutAttribute
                               padding: (CGFloat)padding;

- (void)setQuickPinFillParentWithPadding: (CGFloat)padding;

- (void)setWidth: (CGFloat)width
        relation: (NSLayoutRelation)relation
      multiplier: (CGFloat)multiplier;

- (void)setHeight: (CGFloat)height
         relation: (NSLayoutRelation)relation
       multiplier: (CGFloat)multiplier;

@end

NS_ASSUME_NONNULL_END
