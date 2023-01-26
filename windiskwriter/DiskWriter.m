//
//  DiskWriter.m
//  windiskwriter
//
//  Created by Macintosh on 26.01.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DiskWriter.h"
#import "DebugSystem.h"

@implementation DiskWriter

- (NSString *)getMountedWindowsISO {
    return _mountedWindowsISO;
}

- (NSString *)getDestinationDevice {
    return _destinationDevice;
}

+ (NSString *)getWindowsSourceMountPath: (NSString *)isoPath {
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    BOOL isDirectory;
    BOOL exists = [fileManager fileExistsAtPath:isoPath isDirectory:&isDirectory];
    
    if (!exists) {
        DebugLog(@"File [directory] \"%@\" doesn't exist.", isoPath);
        return NULL;
    }
    
    if (isDirectory) {
        DebugLog(@"The type of the passed \"%@\" is defined as: Directory.", isoPath);
        return isoPath;
    }
    
    DebugLog(@"The type of the passed \"%@\" is defined as: File.", isoPath);
    if (![[isoPath lowercaseString] hasSuffix:@".iso"]) {
        DebugLog(@"This file does not have an .iso extension.");
        return NULL;
    }
    
    
    
    
    return @"";
}

- (instancetype)initWithWindowsISO: (NSString *)windowsISO
                 destinationDevice: (NSString *)destinationDevice {
    if (self) {
        _mountedWindowsISO = [DiskWriter getWindowsSourceMountPath:windowsISO];
        //_mountedWindowsISO = mountedISO;
        _destinationDevice = destinationDevice;
    }
    
    /*if ([mountedWindowsISO hasPrefix: @"/Volumes/"]) {
     
     }*/
    
    return self;
}

@end
