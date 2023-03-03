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

- (void)setWidth: (CGFloat)width
        relation: (NSLayoutRelation)relation
      multiplier: (CGFloat)multiplier {
    
    [self addConstraint: [NSLayoutConstraint constraintWithItem: self
                                                      attribute: NSLayoutAttributeWidth
                                                      relatedBy: relation
                                                         toItem: NULL
                                                      attribute: NSLayoutAttributeNotAnAttribute
                                                     multiplier: multiplier
                                                       constant: width]];
    
}

- (void)setHeight: (CGFloat)height
         relation: (NSLayoutRelation)relation
       multiplier: (CGFloat)multiplier {
    
    [self addConstraint: [NSLayoutConstraint constraintWithItem: self
                                                      attribute: NSLayoutAttributeHeight
                                                      relatedBy: relation
                                                         toItem: NULL
                                                      attribute: NSLayoutAttributeNotAnAttribute
                                                     multiplier: multiplier
                                                       constant: height]];
    
}

- (void)setMinWidth: (CGFloat)minWidth {
    
}

@end
