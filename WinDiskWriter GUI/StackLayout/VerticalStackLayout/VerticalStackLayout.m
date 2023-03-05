//
//  VerticalStackLayout.m
//  WinDiskWriter GUI
//
//  Created by Macintosh on 26.02.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "VerticalStackLayout.h"

@implementation VerticalStackLayout

- (void)addView: (NSView *_Nonnull)newView
        spacing: (CGFloat)spacing {
    [newView setTranslatesAutoresizingMaskIntoConstraints: NO];
    
    [self.containerView addSubview:newView];
    
    if (self.containerView.subviews.count <= 1) {
        [self.containerView addConstraint: [NSLayoutConstraint constraintWithItem: newView
                                                                   attribute: NSLayoutAttributeTop
                                                                   relatedBy: NSLayoutRelationEqual
                                                                      toItem: self.containerView
                                                                   attribute: NSLayoutAttributeTop
                                                                  multiplier: 1.0
                                                                    constant: spacing]];
    } else {
        NSView *previousView = [self.containerView.subviews objectAtIndex: (self.containerView.subviews.count - 2)];
        
        [self.containerView addConstraint: [NSLayoutConstraint constraintWithItem: newView
                                                                   attribute: NSLayoutAttributeTop
                                                                   relatedBy: NSLayoutRelationEqual
                                                                      toItem: previousView
                                                                   attribute: NSLayoutAttributeBottom
                                                                  multiplier: 1.0
                                                                    constant: spacing]];
    }
    
    NSLayoutConstraint *leadingViewConstraint = [NSLayoutConstraint constraintWithItem: newView
                                                                             attribute: NSLayoutAttributeLeading
                                                                             relatedBy: NSLayoutRelationEqual
                                                                                toItem: self.containerView
                                                                             attribute: NSLayoutAttributeLeading
                                                                            multiplier: 1.0
                                                                              constant: 0];
    
    NSLayoutConstraint *weakTrailingViewConstraint = [NSLayoutConstraint constraintWithItem: newView
                                                                                  attribute: NSLayoutAttributeTrailing
                                                                                  relatedBy: NSLayoutRelationEqual
                                                                                     toItem: self.containerView
                                                                                  attribute: NSLayoutAttributeTrailing
                                                                                 multiplier: 1.0
                                                                                   constant: 0];
    [weakTrailingViewConstraint setPriority: NSLayoutPriorityDragThatCannotResizeWindow];
    
    NSLayoutConstraint *trailingViewConstraintAfterWeak = [NSLayoutConstraint constraintWithItem: newView
                                                                                       attribute: NSLayoutAttributeTrailing
                                                                                       relatedBy: NSLayoutRelationLessThanOrEqual
                                                                                          toItem: self.containerView
                                                                                       attribute: NSLayoutAttributeTrailing
                                                                                      multiplier: 1.0
                                                                                        constant: 0];
    
    [self.containerView addConstraints:@[
        leadingViewConstraint,
        weakTrailingViewConstraint,
        trailingViewConstraintAfterWeak
    ]];
    
}





@end
