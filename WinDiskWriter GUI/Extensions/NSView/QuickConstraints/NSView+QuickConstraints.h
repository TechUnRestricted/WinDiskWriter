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

- (void)setQuickPinFillParentWithPadding: (CGFloat)padding;

- (void)setMinWidth: (CGFloat)minWidth;

- (void)setMaxWidth: (CGFloat)minWidth;

- (void)setMinHeight: (CGFloat)minHeight;

- (void)setMaxHeight: (CGFloat)maxHeight;

- (void)setConstraintAttribute: (NSLayoutAttribute)firstAttribute
                        toItem: (id)item
                 itemAttribute: (NSLayoutAttribute)secondAttribute
                      relation: (NSLayoutRelation)relation
                        isWeak: (BOOL)isWeak
                    identifier: (NSString *_Nullable)identifier;

@end

NS_ASSUME_NONNULL_END
