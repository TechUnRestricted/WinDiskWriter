//
//  AppDelegate.h
//  WinDiskWriter GUI
//
//  Created by Macintosh on 13.06.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define WriteExitForce()                \
[self setEnabledUIState: YES];          \
[self->progressBarView resetProgress];  \
return;

#define WriteExitConditionally()      \
if (self.isScheduledForStop) {        \
    WriteExitForce();                 \
}

#define SEMAPHORE_KEY @"Semaphore"
#define NSINTEGER_KEY @"NSInteger"



@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (readwrite, nonatomic) BOOL enabledUIState;
@property (readwrite, nonatomic) BOOL isScheduledForStop;

@end
