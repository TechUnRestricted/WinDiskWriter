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

StackLayoutConstraintIdentifier const StackLayoutConstraintIdentifierWidth = @"width";
StackLayoutConstraintIdentifier const StackLayoutConstraintIdentifierWidthWeak = @"widthWeak";


@implementation HorizontalStackLayout {
    enum HorizontalStackLayoutDistribution _layoutDistribution;
}

- (instancetype)init {
    return [self initWithLayoutDistribution: HorizontalStackLayoutDistributionDefault];
}

- (instancetype)initWithLayoutDistribution: (enum HorizontalStackLayoutDistribution)layoutDistribution {
    self = [super init];
    
    _layoutDistribution = layoutDistribution;
    
    return self;
}

- (void)addViewXXX: (NSView *)newView
           spacing: (CGFloat)spacing {
    
}

- (void)addView: (NSView *_Nonnull)newView
        spacing: (CGFloat)spacing {
    [newView setTranslatesAutoresizingMaskIntoConstraints: NO];
    
    [self.containerView addSubview:newView];
    
    [newView setConstraintAttribute:NSLayoutAttributeHeight toItem:self.containerView itemAttribute:NSLayoutAttributeHeight relation:NSLayoutRelationEqual isWeak:NO constant:0 multiplier: 1.0 identifier:NULL];
    [newView setConstraintAttribute:NSLayoutAttributeTop toItem:self.containerView itemAttribute:NSLayoutAttributeTop relation:NSLayoutRelationEqual isWeak:NO constant:0 multiplier: 1.0 identifier:NULL];
    [newView setConstraintAttribute:NSLayoutAttributeCenterY toItem:self.containerView itemAttribute:NSLayoutAttributeCenterY relation:NSLayoutRelationEqual isWeak:NO constant:0 multiplier: 1.0 identifier:NULL];
    
    NSUInteger subviewsCount = self.containerView.subviews.count;
    
    if (subviewsCount <= 1) {
        [newView setConstraintAttribute:NSLayoutAttributeLeading toItem:self.containerView itemAttribute:NSLayoutAttributeLeading relation:NSLayoutRelationEqual isWeak:NO constant:spacing multiplier: 1.0 identifier:NULL];
    } else {
        NSView *previousView = [self.containerView.subviews objectAtIndex: (self.containerView.subviews.count - 2)];
        
        [self removeConstraintsForFirstOccurenceWithID:StackLayoutConstraintIdentifierTrailing forView:previousView];
        [self removeConstraintsForFirstOccurenceWithID:StackLayoutConstraintIdentifierTrailingWeak forView:previousView];
        
        [newView setConstraintAttribute:NSLayoutAttributeLeading toItem:previousView itemAttribute:NSLayoutAttributeTrailing relation:NSLayoutRelationEqual isWeak:NO constant:spacing multiplier:1.0 identifier:NULL];
    }
    
    [newView setConstraintAttribute:NSLayoutAttributeTrailing toItem:self.containerView itemAttribute:NSLayoutAttributeTrailing relation:NSLayoutRelationEqual isWeak:YES constant:0 multiplier:1.0 identifier:StackLayoutConstraintIdentifierTrailingWeak];
    [newView setConstraintAttribute:NSLayoutAttributeTrailing toItem:self.containerView itemAttribute:NSLayoutAttributeTrailing relation:NSLayoutRelationLessThanOrEqual isWeak:NO constant:0 multiplier:1.0 identifier:StackLayoutConstraintIdentifierTrailing];
    
    if (_layoutDistribution == HorizontalStackLayoutDistributionFillEqually) {
        [self removeAllConstraintsWithID:StackLayoutConstraintIdentifierWidthWeak];
        [self removeAllConstraintsWithID:StackLayoutConstraintIdentifierWidth];

        CGFloat divisionFactor = 1.0 / subviewsCount;
        
        for (NSView *currentSubview in self.containerView.subviews) {
            [currentSubview setConstraintAttribute:NSLayoutAttributeWidth toItem:self.containerView itemAttribute:NSLayoutAttributeWidth relation:NSLayoutRelationEqual isWeak:YES constant:0 multiplier:divisionFactor identifier:StackLayoutConstraintIdentifierWidthWeak];
            [currentSubview setConstraintAttribute:NSLayoutAttributeWidth toItem:self.containerView itemAttribute:NSLayoutAttributeWidth relation:NSLayoutRelationLessThanOrEqual isWeak:NO constant:0 multiplier:divisionFactor identifier:StackLayoutConstraintIdentifierWidth];
        }
    }
}

@end
