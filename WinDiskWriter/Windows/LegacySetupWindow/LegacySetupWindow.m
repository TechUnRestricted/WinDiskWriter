//
//  LegacySetupWindow.m
//  WinDiskWriter
//
//  Created by Macintosh on 02.01.2024.
//  Copyright © 2024 TechUnRestricted. All rights reserved.
//

#import "LegacySetupWindow.h"
#import "HelperFunctions.h"
#import "LocalizedStrings.h"
#import "FrameLayout.h"
#import "LabelView.h"
#import "ButtonView.h"

@implementation LegacySetupWindow

- (instancetype)initWithNSRect: (NSRect)nsRect
                         title: (NSString *)title
                       padding: (CGFloat)padding
        paddingIsTitleBarAware: (BOOL)paddingIsTitleBarAware {
    
    self = [super initWithNSRect: nsRect
                           title: title
                         padding: padding
          paddingIsTitleBarAware: paddingIsTitleBarAware];
    
    [self setupViews];
    
    return self;
}

- (void)setupViews {
    FrameLayoutVertical *mainVerticalLayout = (FrameLayoutVertical *)self.containerView;
    
    LabelView *labelView = [[LabelView alloc] init]; {
        [labelView setStringValue: @"Ayoo"];
        
        [mainVerticalLayout addView: labelView
                              width: INFINITY
                             height: labelView.cell.cellSize.height];
        
    }
    
}

@end
