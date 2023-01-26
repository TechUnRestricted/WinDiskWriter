//
//  DiskWriter.m
//  windiskwriter
//
//  Created by Macintosh on 26.01.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HDIUtil.h"
#import "DiskWriter.h"
#import "DebugSystem.h"

@implementation DiskWriter

- (NSString *)getMountedWindowsISO {
    return _mountedWindowsISO;
}

- (NSString *)getDestinationDevice {
    return _destinationDevice;
}

- (void)initWindowsSourceMountPath: (NSString *)isoPath {
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    BOOL isDirectory;
    BOOL exists = [fileManager fileExistsAtPath:isoPath isDirectory:&isDirectory];
    
    if (!exists) {
        DebugLog(@"File [directory] \"%@\" doesn't exist.", isoPath);
        return;
    }
    
    if (isDirectory) {
        DebugLog(@"The type of the passed \"%@\" is defined as: Directory.", isoPath);
        _mountedWindowsISO = isoPath;
        return;
    }
    
    DebugLog(@"The type of the passed \"%@\" is defined as: File.", isoPath);
    if (![[isoPath lowercaseString] hasSuffix:@".iso"]) {
        DebugLog(@"This file does not have an .iso extension.");
        return;
    }
    
    HDIUtil *hdiutil = [[HDIUtil alloc] initWithImagePath:isoPath];
    if([hdiutil attachImageWithArguments:@[@"-readonly", @"-noverify", @"-noautofsck", @"-noautoopen"]]) {
        _mountedWindowsISO = [hdiutil getMountPoint];
    }
}

- (void)initDestinationDevice: (NSString *)destinationDevice {
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    BOOL isDirectory;
    BOOL exists = [fileManager fileExistsAtPath:destinationDevice isDirectory:&isDirectory];
    
    if (!exists) {
        DebugLog(@"The given Destination path does not exist.");
        return;
    }
    
    if ([destinationDevice hasPrefix:@"/dev/disk"])
    
    return;
    if ([destinationDevice hasPrefix:@"/Volumes/"]) {

        

        
        if (!isDirectory) {
            
            return;
        }
        
        _destinationDevice = destinationDevice;
        return;
    }
}

- (instancetype)initWithWindowsISO: (NSString *)windowsISO
                 destinationDevice: (NSString *)destinationDevice {
    
    [self initWindowsSourceMountPath:windowsISO];
    [self initDestinationDevice:destinationDevice];
    
    
    /*if ([mountedWindowsISO hasPrefix: @"/Volumes/"]) {
     
     }*/
    
    return self;
}

@end
