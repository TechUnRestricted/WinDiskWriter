//
//  main.m
//  WinDiskWriter GUI
//
//  Created by Macintosh on 13.06.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        AppDelegate *appDelegate = [[AppDelegate alloc] init];
        
        NSApplication *application = [NSApplication sharedApplication];
        [application setDelegate:appDelegate];
        
        [application run];
    }
    
    return NSApplicationMain(argc, argv);
}


