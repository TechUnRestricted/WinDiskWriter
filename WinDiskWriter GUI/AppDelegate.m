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
    
    FrameLayoutVertical *tempLayout = [[FrameLayoutVertical alloc] init];
    [mainVerticalLayout addView:tempLayout minWidth:0 maxWidth:INFINITY minHeight:10 maxHeight:100];
    [tempLayout setWantsLayer: YES];
    [tempLayout.layer setBackgroundColor: NSColor.blueColor.toCGColor];
    
    [tempLayout setSpacing: 5];
    
    [tempLayout setHugHeightFrame: YES];
    [tempLayout setHugWidthFrame: YES];
    
    NSButton *button1 = [[NSButton alloc] init];
    [button1 setTitle:@"❤️"];
    [tempLayout addView:button1 minWidth:120 maxWidth:200 minHeight:20 maxHeight:80];
    
    NSButton *button2 = [[NSButton alloc] init];
    [button2 setTitle:@"🗿"];
    [tempLayout addView:button2 minWidth:120 maxWidth:400 minHeight:20 maxHeight:140];

    NSButton *button3 = [[NSButton alloc] init];
    [button3 setTitle:@"🥰"];
    [tempLayout addView:button3 minWidth:5 maxWidth:1200 minHeight:60 maxHeight:140];
    
    FrameLayoutHorizontal *tempHorizontal = [[FrameLayoutHorizontal alloc] init];
    [tempHorizontal setWantsLayer: YES];
    [tempHorizontal.layer setBackgroundColor:NSColor.purpleColor.toCGColor];
    [mainVerticalLayout addView:tempHorizontal minWidth:15 maxWidth:50 minHeight:10 maxHeight:50];
    
    NSButton *button4 = [[NSButton alloc] init];
    [button4 setTitle:@"😰"];
    [tempHorizontal addView:button4 minWidth:65 maxWidth:95 minHeight:50 maxHeight:150];
    
    [tempHorizontal setHugHeightFrame:YES];
    [tempHorizontal setHugWidthFrame:YES];

}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    
}


- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}


@end
