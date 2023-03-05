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

- (void)setQuickPinFillParentWithPadding: (CGFloat)padding {
    [self setQuickPinWithLayoutAttribute: NSLayoutAttributeTop padding: padding];
    [self setQuickPinWithLayoutAttribute: NSLayoutAttributeBottom padding: padding];
    [self setQuickPinWithLayoutAttribute: NSLayoutAttributeLeading padding: padding];
    [self setQuickPinWithLayoutAttribute: NSLayoutAttributeTrailing padding: padding];
}

- (void)setConstraintAttribute: (NSLayoutAttribute)firstAttribute
                        toItem: (id)item
                 itemAttribute: (NSLayoutAttribute)secondAttribute
                      relation: (NSLayoutRelation)relation
                        isWeak: (BOOL)isWeak
                    identifier: (NSString *_Nullable)identifier {
    NSLayoutConstraint *layoutConstraint = [NSLayoutConstraint constraintWithItem: self
                                                                        attribute: firstAttribute
                                                                        relatedBy: relation
                                                                           toItem: item
                                                                        attribute: secondAttribute
                                                                       multiplier: 1.0
                                                                         constant: 0];
    
    if (isWeak) {
        [layoutConstraint setPriority: NSLayoutPriorityDragThatCannotResizeWindow];
    }
    
    [layoutConstraint setIdentifier:identifier];
    
    [self.superview addConstraint: layoutConstraint];
}

- (void)setMinWidth: (CGFloat)minWidth {
    [self addConstraint: [NSLayoutConstraint constraintWithItem: self
                                                      attribute: NSLayoutAttributeWidth
                                                      relatedBy: NSLayoutRelationGreaterThanOrEqual
                                                         toItem: nil
                                                      attribute: NSLayoutAttributeNotAnAttribute
                                                     multiplier: 1.0
                                                       constant: minWidth]];
}

- (void)setMaxWidth: (CGFloat)minWidth {
    [self addConstraint: [NSLayoutConstraint constraintWithItem: self
                                                      attribute: NSLayoutAttributeWidth
                                                      relatedBy: NSLayoutRelationLessThanOrEqual
                                                         toItem: nil
                                                      attribute: NSLayoutAttributeNotAnAttribute
                                                     multiplier: 1.0
                                                       constant: minWidth]];
}

- (void)setMinHeight: (CGFloat)minHeight {
    [self addConstraint: [NSLayoutConstraint constraintWithItem: self
                                                      attribute: NSLayoutAttributeHeight
                                                      relatedBy: NSLayoutRelationGreaterThanOrEqual
                                                         toItem: nil
                                                      attribute: NSLayoutAttributeNotAnAttribute
                                                     multiplier: 1.0
                                                       constant: minHeight]];
}

- (void)setMaxHeight: (CGFloat)maxHeight {
    [self addConstraint: [NSLayoutConstraint constraintWithItem: self
                                                      attribute: NSLayoutAttributeWidth
                                                      relatedBy: NSLayoutRelationLessThanOrEqual
                                                         toItem: nil
                                                      attribute: NSLayoutAttributeNotAnAttribute
                                                     multiplier: 1.0
                                                       constant: maxHeight]];
}

@end
