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
    
    VerticalStackLayout *verticalStackView = [[VerticalStackLayout alloc] init]; {
        [verticalStackView setTranslatesAutoresizingMaskIntoConstraints: NO];
        [mainView addSubview: verticalStackView];
        
        [verticalStackView setQuickPinFillParentWithPaddingTop: _titleBarPaddingValue + defaultElementVerticalPadding
                                                        bottom: defaultMainContentPadding
                                                       leading: defaultMainContentPadding
                                                      trailing: defaultMainContentPadding];
    }
    
    LabelView *labelWindowsSourcePath = [[LabelView alloc] init]; {
        [labelWindowsSourcePath setStringValue:@"Windows.iso / Source Path"];
        [verticalStackView addView:labelWindowsSourcePath spacing:0];
    }
    
    HorizontalStackLayout *horizontalStackLayoutWindowsSourcePath = [[HorizontalStackLayout alloc] init]; {
        [verticalStackView addView:horizontalStackLayoutWindowsSourcePath spacing:defaultElementVerticalPadding];
        
        NSTextField *textFieldWindowsSourcePath = [[NSTextField alloc] init]; {
            [horizontalStackLayoutWindowsSourcePath addView:textFieldWindowsSourcePath spacing:0];
            [textFieldWindowsSourcePath setBezelStyle: NSTextFieldRoundedBezel];
        }
        if (@available(macOS 10.10, *)) {
            [textFieldWindowsSourcePath setPlaceholderString:@"~/Desktop/Windows.iso"];
            [textFieldWindowsSourcePath setLineBreakMode: NSLineBreakByTruncatingHead];
        }
        
        NSButton *buttonChooseImage = [[NSButton alloc] init]; {
            [buttonChooseImage setBezelStyle:NSBezelStyleRounded];
            [buttonChooseImage setTitle:@"Choose"];
            [horizontalStackLayoutWindowsSourcePath addView:buttonChooseImage spacing:defaultMainContentPadding];
            
            [buttonChooseImage setMinWidth:80];
            [buttonChooseImage setMaxWidth:80];
        }
    }
    
    LabelView *labelDeviceSelector = [[LabelView alloc] init]; {
        [verticalStackView addView:labelDeviceSelector spacing:defaultMainContentPadding];
        [labelDeviceSelector setStringValue:@"Device"];
    }
    
    HorizontalStackLayout *horizontalStackLayoutDeviceSelector = [[HorizontalStackLayout alloc] init]; {
        [verticalStackView addView:horizontalStackLayoutDeviceSelector spacing:defaultElementVerticalPadding];
        
        NSPopUpButton *popUpButtonDeviceSelector = [[NSPopUpButton alloc] init]; {
            [horizontalStackLayoutDeviceSelector addView:popUpButtonDeviceSelector spacing:0];
        }
        
        NSButton *buttonUpdateDevices = [[NSButton alloc] init]; {
            [buttonUpdateDevices setBezelStyle:NSBezelStyleRounded];
            [buttonUpdateDevices setTitle:@"Update"];
            [horizontalStackLayoutDeviceSelector addView:buttonUpdateDevices spacing:defaultMainContentPadding];
            
            [buttonUpdateDevices setMinWidth:80];
            [buttonUpdateDevices setMaxWidth:80];
        }
    }
    
    
    LabelView *labelOSType = [[LabelView alloc] init]; {
        [verticalStackView addView:labelOSType spacing:defaultMainContentPadding * 2];
        
        [labelOSType setStringValue:@"OS Type"];
    }
    
    NSPopUpButton *popUpButtonOSType = [[NSPopUpButton alloc] init]; {
        [verticalStackView addView:popUpButtonOSType spacing:defaultElementVerticalPadding];
    }
    
    HorizontalStackLayout *horizontalStackLayoutBootModePartitionScheme = [[HorizontalStackLayout alloc] initWithLayoutDistribution: HorizontalStackLayoutDistributionFillEqually]; {
        [verticalStackView addView:horizontalStackLayoutBootModePartitionScheme spacing:defaultMainContentPadding * 2];
        
        VerticalStackLayout *verticalStackViewBootMode = [[VerticalStackLayout alloc] init]; {
            [horizontalStackLayoutBootModePartitionScheme addView:verticalStackViewBootMode spacing:0];
            
            LabelView *labelViewBootMode = [[LabelView alloc] init];
            [labelViewBootMode setStringValue:@"Boot Mode"];
            [verticalStackViewBootMode addView:labelViewBootMode spacing:0];
            
            NSPopUpButton *popUpButtonBootMode = [[NSPopUpButton alloc] init];
            [verticalStackViewBootMode addView:popUpButtonBootMode spacing:defaultElementVerticalPadding];
        }
        
        VerticalStackLayout *verticalStackViewPartitionScheme = [[VerticalStackLayout alloc] init]; {
            [horizontalStackLayoutBootModePartitionScheme addView:verticalStackViewPartitionScheme spacing:defaultMainContentPadding];
            
            LabelView *labelViewBootMode = [[LabelView alloc] init];
            [labelViewBootMode setStringValue:@"Partition Scheme"];
            [verticalStackViewPartitionScheme addView:labelViewBootMode spacing:0];
            
            NSPopUpButton *popUpButtonBootMode = [[NSPopUpButton alloc] init];
            [verticalStackViewPartitionScheme addView:popUpButtonBootMode spacing:defaultElementVerticalPadding];
        }
    }
    
    HorizontalStackLayout *horizontalStackLayoutFilesystemBlockSize = [[HorizontalStackLayout alloc] initWithLayoutDistribution: HorizontalStackLayoutDistributionFillEqually]; {
        [verticalStackView addView:horizontalStackLayoutFilesystemBlockSize spacing:defaultMainContentPadding * 2];
        
        VerticalStackLayout *verticalStackViewFileSystem = [[VerticalStackLayout alloc] init]; {
            [horizontalStackLayoutFilesystemBlockSize addView:verticalStackViewFileSystem spacing:0];
            
            LabelView *labelViewFilesystem = [[LabelView alloc] init];
            [labelViewFilesystem setStringValue:@"File System"];
            [verticalStackViewFileSystem addView:labelViewFilesystem spacing:0];
            
            NSPopUpButton *popUpButtonFileSystem = [[NSPopUpButton alloc] init];
            [verticalStackViewFileSystem addView:popUpButtonFileSystem spacing:defaultElementVerticalPadding];
        }
        
        VerticalStackLayout *verticalStackViewBlockSize = [[VerticalStackLayout alloc] init]; {
            [horizontalStackLayoutFilesystemBlockSize addView:verticalStackViewBlockSize spacing:defaultMainContentPadding];
            
            LabelView *labelViewBlockSize = [[LabelView alloc] init];
            [labelViewBlockSize setStringValue:@"Block Size"];
            [verticalStackViewBlockSize addView:labelViewBlockSize spacing:0];
            
            NSPopUpButton *popUpButtonBlockSize = [[NSPopUpButton alloc] init];
            [verticalStackViewBlockSize addView:popUpButtonBlockSize spacing:defaultElementVerticalPadding];
        }
    }
    
    VerticalStackLayout *buttonContainer = [[VerticalStackLayout alloc] init]; {
        [verticalStackView addView:buttonContainer spacing:0];
        
        NSButton *checkBox = [[NSButton alloc] init];
        [checkBox setButtonType:NSButtonTypeSwitch];
        [buttonContainer addView:checkBox spacing:0];
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
