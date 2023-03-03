//
//  main.m
//  WinDiskWriter GUI
//
//  Created by Macintosh on 26.02.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AppDelegate/AppDelegate.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSApplication *application = [NSApplication sharedApplication];
        AppDelegate *delegate = [[AppDelegate alloc] init];
        
        [application setDelegate:delegate];
        
        NSApplicationMain(argc, argv);
        [NSApp run];
    }
    return NSApplicationMain(argc, argv);
}
