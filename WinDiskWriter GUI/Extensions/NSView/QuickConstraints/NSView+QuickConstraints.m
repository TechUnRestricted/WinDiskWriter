//
//  NSView+QuickConstraints.m
//  WinDiskWriter GUI
//
//  Created by Macintosh on 26.02.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "NSView+QuickConstraints.h"

@implementation NSView (QuickConstraints)

- (void)setQuickPinWithLayoutAttribute: (NSLayoutAttribute)layoutAttribute
                               padding: (CGFloat)padding {
    if (self.superview == NULL) {
        return;
    }
    
    if (layoutAttribute == NSLayoutAttributeBottom || layoutAttribute == NSLayoutAttributeTrailing) {
        padding *= -1;
    }
    
    [self.superview addConstraint: [NSLayoutConstraint constraintWithItem: self
                                                                attribute: layoutAttribute
                                                                relatedBy: NSLayoutRelationEqual
                                                                   toItem: self.superview
                                                                attribute: layoutAttribute
                                                               multiplier: 1.0
                                                                 constant: padding]];
}

- (void)setQuickPinFillParentWithPaddingTop: (CGFloat)topPadding
                                     bottom: (CGFloat)bottomPadding
                                    leading: (CGFloat)leadingPadding
                                   trailing: (CGFloat)trailingPadding {
    [self setQuickPinWithLayoutAttribute: NSLayoutAttributeTop padding: topPadding];
    [self setQuickPinWithLayoutAttribute: NSLayoutAttributeBottom padding: bottomPadding];
    [self setQuickPinWithLayoutAttribute: NSLayoutAttributeLeading padding: leadingPadding];
    [self setQuickPinWithLayoutAttribute: NSLayoutAttributeTrailing padding: trailingPadding];
}

- (void)setConstraintAttribute: (NSLayoutAttribute)firstAttribute
                        toItem: (id)item
                 itemAttribute: (NSLayoutAttribute)secondAttribute
                      relation: (NSLayoutRelation)relation
                        isWeak: (BOOL)isWeak
                      constant: (CGFloat)constant
                    multiplier: (CGFloat)multiplier
                    identifier: (NSString *_Nullable)identifier {
    NSLayoutConstraint *layoutConstraint = [NSLayoutConstraint constraintWithItem: self
                                                                        attribute: firstAttribute
                                                                        relatedBy: relation
                                                                           toItem: item
                                                                        attribute: secondAttribute
                                                                       multiplier: multiplier
                                                                         constant: constant];
    
    if (isWeak) {
        [layoutConstraint setPriority: NSLayoutPriorityDragThatCannotResizeWindow];
    }
    
    [layoutConstraint setIdentifier:identifier];
    
    [self.superview addConstraint: layoutConstraint];
}

- (void)setMinWidth: (CGFloat)value {
    [self addConstraint: [NSLayoutConstraint constraintWithItem: self
                                                      attribute: NSLayoutAttributeWidth
                                                      relatedBy: NSLayoutRelationGreaterThanOrEqual
                                                         toItem: nil
                                                      attribute: NSLayoutAttributeNotAnAttribute
                                                     multiplier: 1.0
                                                       constant: value]];
}

- (void)setMaxWidth: (CGFloat)value {
    [self addConstraint: [NSLayoutConstraint constraintWithItem: self
                                                      attribute: NSLayoutAttributeWidth
                                                      relatedBy: NSLayoutRelationLessThanOrEqual
                                                         toItem: nil
                                                      attribute: NSLayoutAttributeNotAnAttribute
                                                     multiplier: 1.0
                                                       constant: value]];
}

- (void)setMinHeight: (CGFloat)value {
    [self addConstraint: [NSLayoutConstraint constraintWithItem: self
                                                      attribute: NSLayoutAttributeHeight
                                                      relatedBy: NSLayoutRelationGreaterThanOrEqual
                                                         toItem: nil
                                                      attribute: NSLayoutAttributeNotAnAttribute
                                                     multiplier: 1.0
                                                       constant: value]];
}

- (void)setMaxHeight: (CGFloat)value {
    [self addConstraint: [NSLayoutConstraint constraintWithItem: self
                                                      attribute: NSLayoutAttributeHeight
                                                      relatedBy: NSLayoutRelationLessThanOrEqual
                                                         toItem: nil
                                                      attribute: NSLayoutAttributeNotAnAttribute
                                                     multiplier: 1.0
                                                       constant: value]];
}

@end
