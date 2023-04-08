//
//  HorizontalStackView.m
//  WinDiskWriter GUI
//
//  Created by Macintosh on 06.04.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "HorizontalStackView.h"
#import "NSView+QuickConstraints.h"

@implementation HorizontalStackView

- (void)setLeadingTrailingConstraintsWithNewView: (NSView *)newView
                                    previousView: (NSView *)previousView {
    
}

- (void)addView: (NSView *)newView {
    [super addView:newView];
        
    NSUInteger childViewsCount = self.containerView.subviews.count;

    if (childViewsCount <= 1) {
        
    } else {
        NSView *previousView = [self.containerView.subviews objectAtIndex: (self.containerView.subviews.count - 2)];
        
        
    }
}

@end
