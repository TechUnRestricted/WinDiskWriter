//
//  ContentViewController.m
//  WinDiskWriter GUI
//
//  Created by Macintosh on 26.02.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "ContentViewController.h"
#import "VerticalStackLayout.h"
#import "HorizontalStackLayout.h"
#import "NSView+QuickConstraints.h"
#import "NSColor+Common.h"
#import "LabelView.h"
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface ContentViewController ()

@end

NSView *mainView;
CGFloat _titleBarPaddingValue = 0;
CGFloat defaultMainContentPadding = 10;
CGFloat defaultElementVerticalPadding = 4;

/* Views */

@implementation ContentViewController

- (void)loadView {
    if (@available(macOS 10.10, *)) {
        NSVisualEffectView *visualEffectView = [[NSVisualEffectView alloc] init];
        [visualEffectView setState: NSVisualEffectStateActive];
        [visualEffectView setBlendingMode: NSVisualEffectBlendingModeBehindWindow];
        
        mainView = visualEffectView;
    } else {
        mainView = [[NSView alloc] init];
    }
    
    VerticalStackLayout *verticalStackView = [[VerticalStackLayout alloc] init];
    [verticalStackView setTranslatesAutoresizingMaskIntoConstraints: NO];
    [mainView addSubview: verticalStackView];
    
    [verticalStackView setQuickPinFillParentWithPaddingTop: _titleBarPaddingValue + defaultElementVerticalPadding
                                                    bottom: defaultMainContentPadding
                                                   leading: defaultMainContentPadding
                                                  trailing: defaultMainContentPadding];
    
    LabelView *labelWindowsSourcePath = [[LabelView alloc] init];
    [labelWindowsSourcePath setStringValue:@"Windows.iso / Source Path"];
    [verticalStackView addView:labelWindowsSourcePath spacing:0];
    
    HorizontalStackLayout *horizontalStackLayoutWindowsSourcePath = [[HorizontalStackLayout alloc] init]; {
        [verticalStackView addView:horizontalStackLayoutWindowsSourcePath spacing:defaultElementVerticalPadding];
        
        NSTextField *textFieldWindowsSourcePath = [[NSTextField alloc] init];
        [horizontalStackLayoutWindowsSourcePath addView:textFieldWindowsSourcePath spacing:0];
        
        [textFieldWindowsSourcePath setBezelStyle: NSTextFieldRoundedBezel];
        
        if (@available(macOS 10.10, *)) {
            [textFieldWindowsSourcePath setPlaceholderString:@"~/Desktop/Windows.iso"];
            [textFieldWindowsSourcePath setLineBreakMode: NSLineBreakByTruncatingHead];
        }
        
        NSButton *button = [[NSButton alloc] init];
        [button setBezelStyle:NSBezelStyleRounded];
        [button setTitle:@"Choose"];
        [horizontalStackLayoutWindowsSourcePath addView:button spacing:defaultMainContentPadding];
    }
    
    LabelView *labelDeviceSelector = [[LabelView alloc] init];
    [verticalStackView addView:labelDeviceSelector spacing:defaultMainContentPadding];
    [labelDeviceSelector setStringValue:@"Device"];
    
    HorizontalStackLayout *horizontalStackLayoutDeviceSelector = [[HorizontalStackLayout alloc] init]; {
        [verticalStackView addView:horizontalStackLayoutDeviceSelector spacing:defaultElementVerticalPadding];
        NSPopUpButton *popUpButtonDeviceSelector = [[NSPopUpButton alloc] init];
        [horizontalStackLayoutDeviceSelector addView:popUpButtonDeviceSelector spacing:0];
        
        NSButton *button = [[NSButton alloc] init];
        [button setBezelStyle:NSBezelStyleRounded];
        [button setTitle:@"Update"];
        [horizontalStackLayoutDeviceSelector addView:button spacing:defaultMainContentPadding];
    }
    
    LabelView *labelOSType = [[LabelView alloc] init];
    [labelOSType setStringValue:@"OS Type"];
    [verticalStackView addView:labelOSType spacing:defaultMainContentPadding * 2];
    
    NSPopUpButton *popUpButtonOSType = [[NSPopUpButton alloc] init];
    [verticalStackView addView:popUpButtonOSType spacing:defaultElementVerticalPadding];
    
    HorizontalStackLayout *horizontalStackLayoutBootModePartitionScheme = [[HorizontalStackLayout alloc] init]; {
        [verticalStackView addView:horizontalStackLayoutBootModePartitionScheme spacing:defaultMainContentPadding * 2];
        
        {
        VerticalStackLayout *verticalStackViewBootMode = [[VerticalStackLayout alloc] init];
        [horizontalStackLayoutBootModePartitionScheme addView:verticalStackViewBootMode spacing:0];
        
        LabelView *labelViewBootMode = [[LabelView alloc] init];
        [labelViewBootMode setStringValue:@"Boot Mode"];
        [verticalStackViewBootMode addView:labelViewBootMode spacing:0];
        
        NSPopUpButton *popUpButtonBootMode = [[NSPopUpButton alloc] init];
        [verticalStackViewBootMode addView:popUpButtonBootMode spacing:defaultElementVerticalPadding];
        }
        
        
    }

    
    [self setView: mainView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (instancetype)initWithTitleBarPaddingValue: (CGFloat)titleBarPaddingValue {
    self = [super init];
    _titleBarPaddingValue = titleBarPaddingValue;
    
    return self;
}

@end
