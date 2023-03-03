//
//  VerticalStackLayout.m
//  WinDiskWriter GUI
//
//  Created by Macintosh on 26.02.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "VerticalStackLayout.h"
#import "NSView+QuickConstraints.h"

@implementation VerticalStackLayout

- (void)addView: (NSView *_Nonnull)newView
        spacing: (CGFloat)spacing {
    [newView setTranslatesAutoresizingMaskIntoConstraints: NO];
    
    [self addSubview:newView];

    if (self.subviews.count <= 1) {
        [self addConstraint: [NSLayoutConstraint constraintWithItem: newView
                                                          attribute: NSLayoutAttributeTop
                                                          relatedBy: NSLayoutRelationEqual
                                                             toItem: self
                                                          attribute: NSLayoutAttributeTop
                                                         multiplier: 1.0
                                                           constant: spacing]];
        return;
    }
    
    NSView *secondLastSubview = [self.subviews objectAtIndex: (self.subviews.count - 2)];
    
    [self addConstraint: [NSLayoutConstraint constraintWithItem: newView
                                                      attribute: NSLayoutAttributeTop
                                                      relatedBy: NSLayoutRelationEqual
                                                         toItem: secondLastSubview
                                                      attribute: NSLayoutAttributeBottom
                                                     multiplier: 1.0
                                                       constant: spacing]];
}


- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

@end
