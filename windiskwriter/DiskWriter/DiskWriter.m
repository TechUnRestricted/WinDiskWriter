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
#import "DiskManager.h"
#import "DebugSystem.h"
#import "Filesystems.h"
#import "../Extensions/NSString+Common.h"

@implementation DiskWriter {
    DiskManager *_destinationDeviceDAWrapper;
    
    NSString *_mountedWindowsISO;
    NSString *_destinationDevice;
    //struct DiskInfo windowsImageDiskInfo;
}

- (NSString *)getMountedWindowsISO {
    return _mountedWindowsISO;
}

- (struct DiskInfo)getDestinationDiskInfo {
    return [_destinationDeviceDAWrapper getDiskInfo];
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
    if (![[[isoPath lowercaseString] pathExtension] isEqual: @"iso"]) {
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
    
    if ([destinationDevice hasOneOfThePrefixes:@[
        @"disk", @"/dev/disk",
        @"rdisk", @"/dev/rdisk"
    ]]) {
        DebugLog(@"Received device destination path was defined as BSD Name.");
        _destinationDeviceDAWrapper = [[DiskManager alloc] initWithBSDName:destinationDevice];
    }
    else if ([destinationDevice hasPrefix:@"/Volumes/"]) {
        DebugLog(@"Received device destination path was defined as Mounted Volume.");
        if (@available(macOS 10.7, *)) {
            _destinationDeviceDAWrapper = [[DiskManager alloc] initWithVolumePath:destinationDevice];
        } else {
            // TODO: Fix Mac OS X 10.6 Snow Leopard support
            DebugLog(@"Can't load Destination device info from Mounted Volume. Prevented Unsupported API Call."
                     //"Security measures are ignored. Assume that the user entered everything correctly."
                     );
        }
    }
    
    if ([_destinationDeviceDAWrapper getDiskInfo].BSDName == NULL) {
        DebugLog(@"The specified destination device is invalid.");
    }
}

- (BOOL)writeWindowsISO {
    NSFileManager *localFileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *dirEnum = [localFileManager enumeratorAtPath:_mountedWindowsISO];
    
    NSString *fileName = nil;
    while ((fileName = [dirEnum nextObject])) {
        NSString *sourceFilePath = [_mountedWindowsISO stringByAppendingPathComponent:fileName];
        NSString *destinationPasteFilePath = [_mountedWindowsISO stringByAppendingPathComponent:fileName];
        
        BOOL isDirectory;
        [localFileManager fileExistsAtPath:sourceFilePath isDirectory:&isDirectory];
        
        if (isDirectory) {
            NSError *createDirectoryError;
            BOOL directoryCreated = [localFileManager createDirectoryAtPath:destinationPasteFilePath
                                                withIntermediateDirectories:YES
                                                                 attributes:NULL
                                                                      error:&createDirectoryError];
            DebugLog(@"Creating directory: { %@ } = %@",
                     destinationPasteFilePath,
                     (directoryCreated ? @"Success" : @"Failure")
            );
            
            continue;
        }
        
        NSError *getFileAttributesError;
        NSDictionary *currentFileAttributes = [localFileManager attributesOfItemAtPath:sourceFilePath error:&getFileAttributesError];
        
        if (getFileAttributesError != NULL) {
            DebugLog(@"Can't get \"%@\"file attributes. Let's skip this file...", sourceFilePath);
            continue;
        }
        
        if ([currentFileAttributes fileSize] > 0 && _fileSystem == FilesystemFAT32) {
            if ([[[sourceFilePath lowercaseString] pathExtension] isEqual: @"wim"]) {
                
            }
        }
        
        
        NSError *copyFileError;
        BOOL fileCopied = [localFileManager copyItemAtPath:sourceFilePath
                                                    toPath:destinationPasteFilePath
                                                     error:&copyFileError
        ];
        DebugLog(@"Copying file to: { %@ } = %@",
                 destinationPasteFilePath,
                 (fileCopied ? @"Success": @"Failure")
        );
        
        if (!fileCopied) {
            DebugLog(@"Failure reason: { %@ }",
                [copyFileError localizedFailureReason]
            );
        }
        
    }
    
    return NO;
}

- (instancetype)initWithWindowsISO: (NSString *)windowsISO
                 destinationDevice: (NSString *)destinationDevice
                        filesystem: (Filesystem)filesystem {
    
    [self initWindowsSourceMountPath:windowsISO];
    [self initDestinationDevice:destinationDevice];
    _fileSystem = filesystem;
    
    return self;
}

@end
