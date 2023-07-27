//
//  AppDelegate.m
//  WinDiskWriter GUI
//
//  Created by Macintosh on 13.06.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "AppDelegate.h"
#import "FrameLayout.h"
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
    
    [verticalLayout setWantsLayer: YES];
    [verticalLayout.layer setBackgroundColor: NSColor.redColor.toCGColor];
    
    [verticalLayout setVerticalAlignment: FrameLayoutVerticalTop];
    
    return verticalLayout;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSWindow *currentWindow = [self setupWindow];
    
    CGFloat titlebarHeight = 0;
    if (@available(macOS 10.10, *)) {
        titlebarHeight = currentWindow.contentView.frame.size.height - currentWindow.contentLayoutRect.size.height;
    }
    
    CGFloat verticalLayoutPadding = 14;
    CGFloat horizontaLayoutSpacing = 6;
    
    FrameLayoutVertical *mainVerticalLayout = [self setupMainVerticalViewWithPaddingTop: titlebarHeight + verticalLayoutPadding / 2
                                                                                 bottom: verticalLayoutPadding
                                                                                   left: verticalLayoutPadding
                                                                                  right: verticalLayoutPadding
                                                                                 nsView: currentWindow.contentView];
    
    [mainVerticalLayout setSpacing: verticalLayoutPadding / 2];
    
    FrameLayoutVertical *verticalLayout_1 = [[FrameLayoutVertical alloc] init]; {
        [mainVerticalLayout addView:verticalLayout_1 minWidth:100 maxWidth:400 minHeight:40 maxHeight:40];
        
        [verticalLayout_1 setWantsLayer: YES];
        [verticalLayout_1.layer setBackgroundColor: NSColor.brownColor.toCGColor];
        [verticalLayout_1 setHugHeightFrame: YES];
        [verticalLayout_1 setHugWidthFrame: YES];

        FrameLayoutVertical *verticalLayout_2 = [[FrameLayoutVertical alloc] init]; {
            [verticalLayout_1 addView:verticalLayout_2 minWidth:110 maxWidth:385 minHeight:30 maxHeight:30];
            
            [verticalLayout_2 setWantsLayer: YES];
            [verticalLayout_2.layer setBackgroundColor: NSColor.cyanColor.toCGColor];
            [verticalLayout_2 setHugHeightFrame: YES];
            [verticalLayout_2 setHugWidthFrame: YES];

            FrameLayoutVertical *verticalLayout_3 = [[FrameLayoutVertical alloc] init]; {
                [verticalLayout_2 addView:verticalLayout_3 minWidth:120 maxWidth:380 minHeight:20 maxHeight:20];
                
                [verticalLayout_3 setWantsLayer: YES];
                [verticalLayout_3.layer setBackgroundColor: NSColor.greenColor.toCGColor];
                [verticalLayout_3 setHugHeightFrame: YES];
                [verticalLayout_3 setHugWidthFrame: YES];

                NSButton *button_1 = [[NSButton alloc] init]; {
                    [verticalLayout_3 addView:button_1 minWidth:20 maxWidth:INFINITY minHeight:200 maxHeight:500];
                    [button_1 setTitle:@"🥰"];
                }
            }

            
            
            
        }
        
        
        
    }
    
    
    
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    
}


- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}


@end
