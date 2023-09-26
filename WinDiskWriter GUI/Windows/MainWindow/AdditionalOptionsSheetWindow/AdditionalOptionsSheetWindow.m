//
//  AdditionalOptionsSheetWindow.m
//  WinDiskWriter GUI
//
//  Created by Macintosh on 26.09.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "AdditionalOptionsSheetWindow.h"
#import "FrameLayout.h"
#import "LabelView.h"
#import "CheckBoxView.h"

@implementation AdditionalOptionsSheetWindow

- (instancetype)initWithNSRect: (NSRect)nsRect
                         title: (NSString *)title
                       padding: (CGFloat)padding
        paddingIsTitleBarAware: (BOOL)paddingIsTitleBarAware {
    
    self = [super initWithNSRect: nsRect
                           title: title
                         padding: padding
          paddingIsTitleBarAware: paddingIsTitleBarAware];
    
    FrameLayoutVertical *mainVerticalLayout = (FrameLayoutVertical *)self.containerView;
    [self setupViews];
        
    NSSize minWindowSize = CGSizeMake(100, 100);
    
    [self setMinSize:minWindowSize];
    
    return self;
}

- (void)setupViews {
    FrameLayoutVertical *mainVerticalLayout = (FrameLayoutVertical *)self.containerView;
    
    FrameLayoutVertical *optionsSetVerticalLayout = [[FrameLayoutVertical alloc] init]; {
        [mainVerticalLayout addView:optionsSetVerticalLayout width:INFINITY height:0];
        
        [optionsSetVerticalLayout setHugHeightFrame: YES];
        
        CheckBoxView *writeLegacyMBRBoot = [[CheckBoxView alloc] init]; {
            [optionsSetVerticalLayout addView:writeLegacyMBRBoot width:INFINITY height:writeLegacyMBRBoot.cell.cellSize.height];
        }
    }
}

- (void)cancelOperation: (id)sender {
    [NSApp endSheet: self];
    
    [self close];    
}

@end
