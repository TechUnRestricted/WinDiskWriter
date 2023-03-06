//
//  HorizontalStackLayout.m
//  WinDiskWriter GUI
//
//  Created by Macintosh on 04.03.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "HorizontalStackLayout.h"
#import "NSView+QuickConstraints.h"

StackLayoutConstraintIdentifier const StackLayoutConstraintIdentifierTrailing = @"trailing";
StackLayoutConstraintIdentifier const StackLayoutConstraintIdentifierTrailingWeak = @"trailingWeak";

@implementation HorizontalStackLayout

- (void)addView: (NSView *_Nonnull)newView
        spacing: (CGFloat)spacing {
    [newView setTranslatesAutoresizingMaskIntoConstraints: NO];
    
    [self.containerView addSubview:newView];
    
    [newView setConstraintAttribute:NSLayoutAttributeHeight toItem:self.containerView itemAttribute:NSLayoutAttributeHeight relation:NSLayoutRelationEqual isWeak:NO constant:0 identifier:NULL];
    [newView setConstraintAttribute:NSLayoutAttributeTop toItem:self.containerView itemAttribute:NSLayoutAttributeTop relation:NSLayoutRelationEqual isWeak:NO constant:0 identifier:NULL];
    
    [newView setConstraintAttribute:NSLayoutAttributeCenterY toItem:self.containerView itemAttribute:NSLayoutAttributeCenterY relation:NSLayoutRelationEqual isWeak:NO constant:0 identifier:NULL];

    
    if (self.containerView.subviews.count <= 1) {
        [newView setConstraintAttribute:NSLayoutAttributeLeading toItem:self.containerView itemAttribute:NSLayoutAttributeLeading relation:NSLayoutRelationEqual isWeak:NO constant:spacing identifier:NULL];
    } else {
        NSView *previousView = [self.containerView.subviews objectAtIndex: (self.containerView.subviews.count - 2)];
        
        NSArray *parentLayoutConstraints = self.containerView.constraints;
        
        BOOL trailingRemoved = NO;
        BOOL weakTrailingRemoved = NO;
        
        for (NSInteger i = parentLayoutConstraints.count - 1; i >= 0; --i) {
            NSLayoutConstraint *currentConstraint = [parentLayoutConstraints objectAtIndex:i];
            
            if (trailingRemoved && weakTrailingRemoved) {
                break;
            }
            
            if (![currentConstraint.firstItem isEqual:previousView]) {
                continue;
            }
            
            if (currentConstraint.identifier == StackLayoutConstraintIdentifierTrailing) {
                [self.containerView removeConstraint:currentConstraint];
                trailingRemoved = YES;
                continue;
            }
            
            if (currentConstraint.identifier == StackLayoutConstraintIdentifierTrailingWeak) {
                [self.containerView removeConstraint:currentConstraint];
                weakTrailingRemoved = YES;
                continue;
            }
        }
        
        [newView setConstraintAttribute:NSLayoutAttributeLeading toItem:previousView itemAttribute:NSLayoutAttributeTrailing relation:NSLayoutRelationEqual isWeak:NO constant:spacing identifier:NULL];
    }
    
    [newView setConstraintAttribute:NSLayoutAttributeTrailing toItem:self.containerView itemAttribute:NSLayoutAttributeTrailing relation:NSLayoutRelationEqual isWeak:YES constant:0 identifier:StackLayoutConstraintIdentifierTrailingWeak];
    [newView setConstraintAttribute:NSLayoutAttributeTrailing toItem:self.containerView itemAttribute:NSLayoutAttributeTrailing relation:NSLayoutRelationLessThanOrEqual isWeak:NO constant:0 identifier:StackLayoutConstraintIdentifierTrailing];
}

@end
