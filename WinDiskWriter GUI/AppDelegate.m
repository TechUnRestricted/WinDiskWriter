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
   
    FrameLayoutVertical *layout = [[FrameLayoutVertical alloc] initWithFrame:CGRectMake(0, 0, _containerView.frame.size.width, _containerView.frame.size.height)]; {
        [layout setAutoresizingMask: (NSAutoresizingMaskOptions)NSViewAutoresizingFlexibleWidth | (NSAutoresizingMaskOptions)NSViewAutoresizingFlexibleHeight];
        [_containerView addSubview:layout];
        
        [layout setWantsLayer: YES];
        [[layout layer] setBackgroundColor: NSColor.redColor.toCGColor];
        
        [layout setHorizontalAlignment:FrameLayoutHorizontalRight];
        [layout setVerticalAlignment:FrameLayoutVerticalTop];
    }


    NSButton *button1 = [[NSButton alloc] init]; {
        [layout addView:button1 minWidth:100 maxWidth:300 minHeight:140 maxHeight:200];

        [button1 setTitle:@"Button 1"];
        [button1 setBordered: YES];
        [button1 setBezelStyle: NSBezelStyleRegularSquare];
    }

    NSButton *button2 = [[NSButton alloc] init]; {
        [layout addView:button2 minWidth:80 maxWidth:340 minHeight:100 maxHeight:140];

        [button2 setTitle:@"Button 2"];
        [button2 setBordered: YES];
        [button2 setBezelStyle: NSBezelStyleRegularSquare];
    }
    
    
    [_window setMovableByWindowBackground: YES];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    
}


- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}


@end
