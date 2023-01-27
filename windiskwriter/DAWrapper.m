//
//  DAWrapper.m
//  windiskwriter
//
//  Created by Macintosh on 27.01.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import <DiskArbitration/DiskArbitration.h>
#import <Foundation/Foundation.h>
#import "DAWrapper.h"
#import "DebugSystem.h"

@implementation DAWrapper {
    DASessionRef diskSession;
    DADiskRef currentDisk;
}

- (void)initDiskSession {
    diskSession = DASessionCreate(kCFAllocatorDefault);
}

- (instancetype _Nullable)initWithBSDName: (NSString * _Nonnull)bsdName {
    [self initDiskSession];
    currentDisk = DADiskCreateFromBSDName(kCFAllocatorDefault, diskSession, [bsdName UTF8String]);
    
    if (currentDisk == NULL) {
        DebugLog(@"Can't create DADisk from BSD Name.");
    } else {
        DebugLog(@"Successfully created DADisk from BSD Name.");
    }
    
    return self;
}

- (instancetype _Nullable)initWithVolumePath: (NSString * _Nonnull)volumePath {
    [self initDiskSession];
    currentDisk = DADiskCreateFromVolumePath(kCFAllocatorDefault, diskSession, (CFURLRef)[NSURL fileURLWithPath:volumePath]);
    
    if (currentDisk == NULL) {
        DebugLog(@"Can't create DADisk from Volume Path.");
    } else {
        DebugLog(@"Successfully created DADisk from Volume Path.");
    }
    
    return self;
}

@end
