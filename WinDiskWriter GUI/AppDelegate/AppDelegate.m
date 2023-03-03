//
//  AppDelegate.m
//  WinDiskWriter GUI
//
//  Created by Macintosh on 26.02.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "AppDelegate.h"
#import "ContentViewController.h"
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface AppDelegate ()

@end

NSWindow *window;
NSViewController *contentViewController;

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    contentViewController = [[ContentViewController alloc] init];
    
    NSRect windowRectangle = NSMakeRect(500.0,   // X
                                        500.0,   // Y
                                        480,  // Width
                                        360); // Height
    
    NSWindowStyleMask windowStyleMask = NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskClosable | NSWindowStyleMaskResizable | NSWindowStyleMaskTitled;

    window = [[NSWindow alloc] initWithContentRect: windowRectangle
                                         styleMask: windowStyleMask
                                           backing: NSBackingStoreBuffered
                                             defer: NO];
    if (@available(macOS 90.10, *)) {
        window.styleMask |= NSFullSizeContentViewWindowMask;
        [window setTitlebarAppearsTransparent: YES];
    }
    
    [window center];
    [window setTitle: @"WinDiskWriter GUI"];
    [window setContentView: contentViewController.view];
    [window makeKeyAndOrderFront: NULL];
    [window setMovableByWindowBackground: YES];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}


@end
