//
//  AppDelegate.m
//  WinDiskWriter GUI
//
//  Created by Macintosh on 13.06.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "AppDelegate.h"
#import "FrameLayout.h"
#import "LabelView.h"
#import "ButtonView.h"
#import "PickerView.h"
#import "TextInputView.h"
#import "CheckBoxView.h"
#import "AutoScrollTextView.h"

#import "Extensions/NSColor/NSColor+Common.h"

typedef NS_OPTIONS(NSUInteger, NSViewAutoresizing) {
    NSViewAutoresizingNone                 = NSViewNotSizable,
    NSViewAutoresizingFlexibleLeftMargin   = NSViewMinXMargin,
    NSViewAutoresizingFlexibleWidth        = NSViewWidthSizable,
    NSViewAutoresizingFlexibleRightMargin  = NSViewMaxXMargin,
    NSViewAutoresizingFlexibleTopMargin    = NSViewMaxYMargin,
    NSViewAutoresizingFlexibleHeight       = NSViewHeightSizable,
    NSViewAutoresizingFlexibleBottomMargin = NSViewMinYMargin
};

@interface AppDelegate ()

@end

@implementation AppDelegate

- (NSWindow *)setupWindow {
    NSRect windowRect = NSMakeRect(
                                   0, // X
                                   0, // Y
                                   380, // Width
                                   500 // Height
                                   );
    
    NSWindow *window = [[NSWindow alloc] initWithContentRect: windowRect
                                                   styleMask: NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask
                                                     backing: NSBackingStoreBuffered
                                                       defer: NO
    ];
    
    [window center];
    [window setMovableByWindowBackground: YES];
    [window makeKeyAndOrderFront:nil];
    
    [window setTitle: @"WinDiskWriter GUI"];
    
    if (@available(macOS 10.10, *)) {
        [window setTitlebarAppearsTransparent: YES];
    }
    
    NSView *backgroundView;
    
    if (@available(macOS 10.10, *)) {
        NSVisualEffectView *visualEffectView = [[NSVisualEffectView alloc] initWithFrame:window.frame];
        
        [visualEffectView setState:NSVisualEffectStateActive];
        [visualEffectView setBlendingMode:NSVisualEffectBlendingModeBehindWindow];
        
        backgroundView = visualEffectView;
        
        window.styleMask |= NSWindowStyleMaskFullSizeContentView;
    } else {
        backgroundView = [[NSView alloc] init];
    }
    
    [window setContentView: backgroundView];
    
    return window;
}

- (FrameLayoutVertical *)setupMainVerticalViewWithPaddingTop: (CGFloat)top
                                         bottom: (CGFloat)bottom
                                           left: (CGFloat)left
                                          right: (CGFloat)right
                                         nsView: (NSView *)nsView {
    CGFloat x = left;
    CGFloat y = bottom;
    CGFloat width = nsView.frame.size.width - left - right;
    CGFloat height = nsView.frame.size.height - top - bottom;
    
    CGRect windowRect = CGRectMake(x, y, width, height);
    
    FrameLayoutVertical *verticalLayout = [[FrameLayoutVertical alloc] initWithFrame: windowRect];
    [nsView addSubview:verticalLayout];
    
    [verticalLayout setAutoresizingMask: NSViewAutoresizingFlexibleWidth | NSViewAutoresizingFlexibleHeight];
    
    [verticalLayout setVerticalAlignment: FrameLayoutVerticalTop];
    
    return verticalLayout;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSWindow *currentWindow = [self setupWindow];
    NSView *spacerView = [[NSView alloc] init];

    CGFloat titlebarHeight = 0;
    if (@available(macOS 10.10, *)) {
        titlebarHeight = currentWindow.contentView.frame.size.height - currentWindow.contentLayoutRect.size.height;
    }
    
    const CGFloat mainContentGroupsSpacing = 6;
    const CGFloat childElementsSpacing = 6;
    
    FrameLayoutVertical *mainVerticalLayout = [self setupMainVerticalViewWithPaddingTop: titlebarHeight + childElementsSpacing / 2
                                                                                 bottom: childElementsSpacing
                                                                                   left: childElementsSpacing
                                                                                  right: childElementsSpacing
                                                                                 nsView: currentWindow.contentView];
    
    [mainVerticalLayout setSpacing: mainContentGroupsSpacing];
    
    FrameLayoutVertical *isoPickerVerticalLayout = [[FrameLayoutVertical alloc] init]; {
        [mainVerticalLayout addView:isoPickerVerticalLayout width:INFINITY height:0];
        
        [isoPickerVerticalLayout setHugHeightFrame: YES];
        
        [isoPickerVerticalLayout setSpacing: childElementsSpacing];
        
        LabelView *isoPickerLabelView = [[LabelView alloc] init]; {
            [isoPickerVerticalLayout addView:isoPickerLabelView width:INFINITY height:isoPickerLabelView.cell.cellSize.height];
            
            [isoPickerLabelView setStringValue: @"Windows Image"];
                        
            [isoPickerLabelView setWantsLayer: YES];            
        }
        
        FrameLayoutHorizontal *isoPickerHorizontalLayout = [[FrameLayoutHorizontal alloc] init]; {
            [isoPickerVerticalLayout addView:isoPickerHorizontalLayout width:INFINITY height:0];
            
            [isoPickerHorizontalLayout setHugHeightFrame: YES];
            
            [isoPickerHorizontalLayout setVerticalAlignment: FrameLayoutVerticalCenter];
            
            [isoPickerHorizontalLayout setSpacing: childElementsSpacing];
            
            TextInputView *windowsImageInputView = [[TextInputView alloc] init]; {
                [isoPickerHorizontalLayout addView:windowsImageInputView width:INFINITY height:windowsImageInputView.cell.cellSize.height];
                
                if (@available(macOS 10.10, *)) {
                    [windowsImageInputView setPlaceholderString: @"/path/to/Windows.iso"];
                }
            }
        
            ButtonView *chooseWindowsImageButtonView = [[ButtonView alloc] init]; {
                [isoPickerHorizontalLayout addView:chooseWindowsImageButtonView minWidth:80 maxWidth:100 minHeight:0 maxHeight:INFINITY];
                
                [chooseWindowsImageButtonView setTitle:@"Choose"];
            }
        }
    }
    
    FrameLayoutVertical *devicePickerVerticalLayout = [[FrameLayoutVertical alloc] init]; {
        [mainVerticalLayout addView:devicePickerVerticalLayout width:INFINITY height:0];
    
        [devicePickerVerticalLayout setHugHeightFrame:YES];
        
        [devicePickerVerticalLayout setSpacing: childElementsSpacing];

        
        LabelView *devicePickerLabelView = [[LabelView alloc] init]; {
            [devicePickerVerticalLayout addView:devicePickerLabelView width:INFINITY height:devicePickerLabelView.cell.cellSize.height];
            
            [devicePickerLabelView setStringValue: @"Target Device"];
        }

        FrameLayoutHorizontal *devicePickerHorizontalLayout = [[FrameLayoutHorizontal alloc] init]; {
            [devicePickerVerticalLayout addView:devicePickerHorizontalLayout width:INFINITY height:0];

            [devicePickerHorizontalLayout setHugHeightFrame:YES];

            PickerView *devicePickerView = [[PickerView alloc] init]; {
                [devicePickerHorizontalLayout addView:devicePickerView minWidth:0 maxWidth:INFINITY minHeight:0 maxHeight:devicePickerView.cell.cellSize.height];
                                
                [devicePickerView addItemWithTitle: @"Первый"];
                [devicePickerView addItemWithTitle: @"Второй"];
                [devicePickerView addItemWithTitle: @"Третий"];
            }
            
            ButtonView *updateDeviceListButtonView = [[ButtonView alloc] init]; {
                [devicePickerHorizontalLayout addView:updateDeviceListButtonView minWidth:80 maxWidth:100 minHeight:0 maxHeight:INFINITY];
                
                [updateDeviceListButtonView setTitle:@"Update"];
            }
        }
    }
    
    [mainVerticalLayout addView:spacerView width:INFINITY height: 3];
    
    CheckBoxView *checkboxView = [[CheckBoxView alloc] init]; {
        [mainVerticalLayout addView:checkboxView width:INFINITY height:checkboxView.cell.cellSize.height];
        
        [checkboxView setTitle: @"Format Device"];
    }
    
    [mainVerticalLayout addView:spacerView width:INFINITY height: 3];

    
    FrameLayoutVertical *formattingSectionVerticalLayout = [[FrameLayoutVertical alloc] init]; {
        [mainVerticalLayout addView:formattingSectionVerticalLayout width:INFINITY height:0];
        
        [formattingSectionVerticalLayout setHugHeightFrame: YES];
        [formattingSectionVerticalLayout setSpacing:childElementsSpacing];
        
        FrameLayoutVertical *fileSystemPickerVerticalLayout = [[FrameLayoutVertical alloc] init]; {
            [formattingSectionVerticalLayout addView:fileSystemPickerVerticalLayout width:INFINITY height:0];
            [fileSystemPickerVerticalLayout setHugHeightFrame: YES];
            
            [fileSystemPickerVerticalLayout setSpacing:childElementsSpacing];
            
            LabelView *filesystemLabelView = [[LabelView alloc] init]; {
                [fileSystemPickerVerticalLayout addView:filesystemLabelView width:INFINITY height:filesystemLabelView.cell.cellSize.height];
                
                [filesystemLabelView setStringValue: @"File System"];
            }
            
            NSSegmentedControl *filesystemPickerSegmentedControl = [[NSSegmentedControl alloc] init]; {
                [filesystemPickerSegmentedControl setSegmentCount:2];
            
                [filesystemPickerSegmentedControl setLabel:@"FAT32" forSegment:0];
                [filesystemPickerSegmentedControl setLabel:@"ExFAT" forSegment:1];
                
                [filesystemPickerSegmentedControl setSelectedSegment:0];
                
                [fileSystemPickerVerticalLayout addView:filesystemPickerSegmentedControl width:INFINITY height:filesystemPickerSegmentedControl.cell.cellSize.height];
            }
        }
        
        FrameLayoutVertical *partitionSchemePickerVerticalLayout = [[FrameLayoutVertical alloc] init]; {
            [formattingSectionVerticalLayout addView:partitionSchemePickerVerticalLayout width:INFINITY height:0];
            
            [partitionSchemePickerVerticalLayout setHugHeightFrame: YES];
            [partitionSchemePickerVerticalLayout setSpacing: childElementsSpacing];
            
            LabelView *partitionSchemeLabelView = [[LabelView alloc] init]; {
                [partitionSchemePickerVerticalLayout addView: partitionSchemeLabelView
                                                    minWidth: 0
                                                    maxWidth: INFINITY
                                                   minHeight: partitionSchemeLabelView.cell.cellSize.height
                                                   maxHeight: partitionSchemeLabelView.cell.cellSize.height];
            
                [partitionSchemeLabelView setStringValue:@"Partition Scheme"];
            }
            
            NSSegmentedControl *partitionSchemePickerSegmentedControl = [[NSSegmentedControl alloc] init]; {
                [partitionSchemePickerSegmentedControl setSegmentCount:2];
            
                [partitionSchemePickerSegmentedControl setLabel:@"MBR" forSegment:0];
                [partitionSchemePickerSegmentedControl setLabel:@"GPT" forSegment:1];
                
                [partitionSchemePickerSegmentedControl setSelectedSegment:0];
                
                [partitionSchemePickerVerticalLayout addView:partitionSchemePickerSegmentedControl minWidth:0 maxWidth:INFINITY minHeight:partitionSchemePickerSegmentedControl.cell.cellSize.height maxHeight:partitionSchemePickerSegmentedControl.cell.cellSize.height];
            }
        }
        
    }
    
    [mainVerticalLayout addView:spacerView width:4 height:4];
    
    AutoScrollTextView *logsAutoScrollTextView = [[AutoScrollTextView alloc] init]; {
        [mainVerticalLayout addView:logsAutoScrollTextView minWidth:0 maxWidth:INFINITY minHeight:120 maxHeight:240];
        
        
    
    }
    [mainVerticalLayout addView:spacerView width:4 height:4];

    FrameLayoutVertical *startStopVerticalLayout = [[FrameLayoutVertical alloc] init]; {
        [mainVerticalLayout addView:startStopVerticalLayout width:INFINITY height:INFINITY];
        
        [startStopVerticalLayout setHorizontalAlignment: FrameLayoutHorizontalCenter];
        [startStopVerticalLayout setVerticalAlignment: FrameLayoutVerticalCenter];
        
        [startStopVerticalLayout setSpacing:10];
        
        [startStopVerticalLayout setHugHeightFrame: NO];
        
        ButtonView *startStopButtonView = [[ButtonView alloc] init]; {
            [startStopVerticalLayout addView:startStopButtonView minWidth:40 maxWidth:180 minHeight:startStopButtonView.cell.cellSize.height maxHeight:startStopButtonView.cell.cellSize.height];
            
            [startStopButtonView setTitle: @"Start"];
        }
        
        NSProgressIndicator *progressIndicator = [[NSProgressIndicator alloc] init]; {
            [startStopVerticalLayout addView:progressIndicator width:INFINITY height:8];

        }
    }
    

    
    LabelView *developerNameLabelView = [[LabelView alloc] init]; {
        [mainVerticalLayout addView:developerNameLabelView width:INFINITY height:developerNameLabelView.cell.cellSize.height];
        
        [developerNameLabelView setAlignment:NSTextAlignmentCenter];
        
        [developerNameLabelView setStringValue: @"TechUnRestricted 2023"];
    }
    
    
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    
}


- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}

@end
