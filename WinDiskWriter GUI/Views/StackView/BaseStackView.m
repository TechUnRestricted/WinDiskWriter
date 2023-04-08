//
//  BaseStackView.m
//  WinDiskWriter GUI
//
//  Created by Macintosh on 05.04.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "BaseStackView.h"
#import "NSView+QuickConstraints.h"

@implementation BaseStackView {
    CGFloat spacing;
}

- (instancetype)init {
    self = [super init];
    
    _containerView = [[NSView alloc] init];
    
    [_containerView setTranslatesAutoresizingMaskIntoConstraints: NO];
    
    [self addSubview: _containerView];
    
    [_containerView setConstraintAttribute:NSLayoutAttributeWidth toItem:self itemAttribute:NSLayoutAttributeWidth relation:NSLayoutRelationEqual isWeak:NO constant:0 multiplier:1.0 identifier:NULL];
    [_containerView setConstraintAttribute:NSLayoutAttributeHeight toItem:self itemAttribute:NSLayoutAttributeHeight relation:NSLayoutRelationEqual isWeak:NO constant:0 multiplier:1.0 identifier:NULL];
    
    return self;
}

- (void)addView: (NSView *)newView {
    [newView setTranslatesAutoresizingMaskIntoConstraints: NO];
    
    [self.containerView addSubview:newView];
}

- (CGFloat)spacing {
    return spacing;
}

- (void)setSpacing: (CGFloat)newSpacing {
    spacing = newSpacing;
}

- (void)removeConstraintsForFirstOccurenceWithID: (StackLayoutConstraintIdentifier)constraintID
                                         forView: (NSView *)nsView {
    NSArray *parentLayoutConstraints = self.containerView.constraints;
    
    for (NSInteger i = parentLayoutConstraints.count - 1; i >= 0; --i) {
        NSLayoutConstraint *currentConstraint = [parentLayoutConstraints objectAtIndex:i];
        
        if (![currentConstraint.firstItem isEqual:nsView]) {
            continue;
        }
        
        if (currentConstraint.identifier == constraintID) {
            [self.containerView removeConstraint:currentConstraint];
            break;
        }
    }
}

- (void)removeAllConstraintsWithID: (StackLayoutConstraintIdentifier)constraintID {
    NSArray *parentLayoutConstraints = self.containerView.constraints;
    
    for (NSInteger i = parentLayoutConstraints.count - 1; i >= 0; --i) {
        NSLayoutConstraint *currentConstraint = [parentLayoutConstraints objectAtIndex:i];
        
        if (currentConstraint.identifier == constraintID) {
            [self.containerView removeConstraint:currentConstraint];
        }
        
    }
}

@end
