//
//  BaseStackLayout.m
//  WinDiskWriter GUI
//
//  Created by Macintosh on 05.03.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "BaseStackLayout.h"

StackLayoutConstraintIdentifier const StackLayoutConstraintIdentifierTrailing = @"trailing";
StackLayoutConstraintIdentifier const StackLayoutConstraintIdentifierTrailingWeak = @"trailingWeak";

@implementation BaseStackLayout

- (instancetype)init {
    self = [super init];
    
    _containerView = [[NSView alloc] init];
    
    [_containerView setTranslatesAutoresizingMaskIntoConstraints: NO];
    
    [self addSubview: _containerView];
    
    [self addConstraints: @[
        [NSLayoutConstraint constraintWithItem: _containerView
                                     attribute: NSLayoutAttributeWidth
                                     relatedBy: NSLayoutRelationEqual
                                        toItem: self
                                     attribute: NSLayoutAttributeWidth
                                    multiplier: 1.0
                                      constant: 0.0],
        [NSLayoutConstraint constraintWithItem: _containerView
                                     attribute: NSLayoutAttributeHeight
                                     relatedBy: NSLayoutRelationEqual
                                        toItem: self
                                     attribute: NSLayoutAttributeHeight
                                    multiplier: 1.0
                                      constant: 0.0]]
    ];
    
    return self;
}

@end
