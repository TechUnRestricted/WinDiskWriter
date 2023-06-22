//
//  AppDelegate.m
//  WinDiskWriter GUI
//
//  Created by Macintosh on 13.06.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "AppDelegate.h"
#import "VerticalLayout.h"
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
   
    VerticalLayout *verticalLayout = [[VerticalLayout alloc] initWithFrame:CGRectMake(0, 0, _containerView.frame.size.width, 30)]; {
        [verticalLayout setAutoresizingMask: (NSAutoresizingMaskOptions)NSViewAutoresizingFlexibleWidth];
        [_containerView addSubview:verticalLayout];
        
        [verticalLayout setWantsLayer: YES];
        [[verticalLayout layer] setBackgroundColor: NSColor.redColor.toCGColor];
    }
  
    NSTextField *textField = [[NSTextField alloc] init];
    [textField setBordered: YES];
    [textField setBezeled: YES];
    [textField setBezelStyle: NSTextFieldRoundedBezel];
    
    [verticalLayout addView:textField minWidth:100 maxWidth:INFINITY minHeight:0 maxHeight:INFINITY];
    
    NSButton *button = [[NSButton alloc] init];
    [button setTitle:@"Choose"];
    [button setBordered: YES];
    [button setBezelStyle: NSBezelStyleRounded];
    
    [verticalLayout addView:button];

    
    [_window setMovableByWindowBackground: YES];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    
}


- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}


@end
