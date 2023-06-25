//
//  AppDelegate.m
//  WinDiskWriter GUI
//
//  Created by Macintosh on 13.06.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "AppDelegate.h"
#import "HorizontalLayout.h"
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
@property (unsafe_unretained) IBOutlet NSTextField *textFieldISOPicker;

@property (unsafe_unretained) IBOutlet NSView *containerView;

@property (strong) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

    if (@available(macOS 10.10, *)) {
        NSVisualEffectView *visualEffectView = [[NSVisualEffectView alloc] initWithFrame:_containerView.frame];
        
        [visualEffectView setState:NSVisualEffectStateActive];
        [visualEffectView setBlendingMode:NSVisualEffectBlendingModeBehindWindow];
        
        
        [_containerView addSubview:visualEffectView positioned:NSWindowBelow relativeTo:nil];
        [visualEffectView setAutoresizingMask: NSViewAutoresizingFlexibleWidth | NSViewAutoresizingFlexibleHeight];

    }
   
    HorizontalLayout *horizontalLayout = [[HorizontalLayout alloc] initWithFrame:CGRectMake(0, 0, _containerView.frame.size.width, 30)]; {
        [horizontalLayout setAutoresizingMask: (NSAutoresizingMaskOptions)NSViewAutoresizingFlexibleWidth];
        [_containerView addSubview:horizontalLayout];
        
        [horizontalLayout setWantsLayer: YES];
        [[horizontalLayout layer] setBackgroundColor: NSColor.redColor.toCGColor];
    }
  
    
    NSTextField *textField1 = [[NSTextField alloc] init];
    [horizontalLayout addView:textField1 minWidth:5 maxWidth:200 minHeight:10 maxHeight:10];
    
    NSTextField *textField2 = [[NSTextField alloc] init];
    [horizontalLayout addView:textField2 minWidth:5 maxWidth:300 minHeight:2 maxHeight:INFINITY];
    
    [horizontalLayout setSpacing:10];
    
    NSButton *button = [[NSButton alloc] init];
    [button setTitle:@"Choose"];
    [button setBordered: YES];
    [button setBezelStyle: NSBezelStyleRounded];
    
    [horizontalLayout setVerticalAlignment:FrameLayoutVerticalTop];
    //[verticalLayout addView:button];
    
    
    [_window setMovableByWindowBackground: YES];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    
}


- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}


@end
