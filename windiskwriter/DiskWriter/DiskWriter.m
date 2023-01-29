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

const uint32_t FAT32_MAX_FILE_SIZE = 4294967295;

@implementation DiskWriter {
    // DiskManager *_sourceDeviceDAWrapper;
    DiskManager *_destinationDeviceDAWrapper;
    
    NSString *_mountedWindowsISO;
    NSString *_destinationDevice;
}

- (NSString * _Nullable)getMountedWindowsISO {
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
    if (![[[isoPath lowercaseString] pathExtension] isEqualToString: @"iso"]) {
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
            DebugLog(@"Can't load Destination device info from Mounted Volume. Prevented Unsupported API Call. Specify the device using the BSD name."
            );
        }
    }
    
    if ([_destinationDeviceDAWrapper getDiskInfo].BSDName == NULL) {
        DebugLog(@"The specified destination device is invalid.");
    }
}

- (BOOL)writeWindowsISO {
    struct DiskInfo destinationDiskInfo = [_destinationDeviceDAWrapper getDiskInfo];
    
    if (!destinationDiskInfo.isBSDUnit) {
        DebugLog(@"The specified destination device does not appear to be valid, as it has been determined that it is not a BSD device.");
        return NO;
    }
    
    BOOL eraseWasSuccessful = NO;
    if (destinationDiskInfo.isWholeDrive) {
        DebugLog(@"Formatting the entire disk with the following options: [PartitionScheme: \"%@\"; Filesystem: \"%@\"]",
                 PartitionSchemeMBR,
                 _filesystem
        );
        eraseWasSuccessful = [_destinationDeviceDAWrapper diskUtilEraseDiskWithPartitionScheme: PartitionSchemeMBR
                                                                                    filesystem: _filesystem
                                                                                       newName: NULL];
    } else {
        DebugLog(@"Formatting the volume with the following options: [Filesystem: \"%@\"]",
                 _filesystem
        );
        eraseWasSuccessful = [_destinationDeviceDAWrapper diskUtilEraseVolumeWithFilesystem: _filesystem
                                                                                    newName: NULL];
        
    }
    
    if (eraseWasSuccessful) {
        DebugLog(@"Formatting completed successfully!");
    } else {
        DebugLog(@"An error occurred during formatting.");
        return NO;
    }
    
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
            BOOL directoryCreated = [localFileManager createDirectoryAtPath: destinationPasteFilePath
                                                withIntermediateDirectories: YES
                                                                 attributes: NULL
                                                                      error: &createDirectoryError];
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
        
        if ([currentFileAttributes fileSize] > FAT32_MAX_FILE_SIZE && _filesystem == FilesystemFAT32) {
            NSString *filePathExtension = [[sourceFilePath lowercaseString] pathExtension];
            
            if ([filePathExtension isEqualToString: @"wim"]) {
                // TODO: Implement .wim file splitting
            } else if ([filePathExtension isEqualToString:@"esd"]) {
                // TODO: Implement .esd file splitting
                DebugLog(@"Splitting .esd files into multiple parts is currently not available. Further copying is pointless...");
                return NO;
            } else {
                DebugLog(@"This file cannot be copied to FAT32 because this type of file cannot be splitted into multiple parts. Further copying is pointless...");
                return NO;
            }
        }
        
        
        NSError *copyFileError;
        BOOL fileCopied = [localFileManager copyItemAtPath: sourceFilePath
                                                    toPath: destinationPasteFilePath
                                                     error: &copyFileError
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

- (instancetype)initWithWindowsISO: (NSString * _Nonnull)windowsISO
                 destinationDevice: (NSString * _Nonnull)destinationDevice
                        filesystem: (Filesystem _Nonnull)filesystem {
    
    [self initWindowsSourceMountPath:windowsISO];
    [self initDestinationDevice:destinationDevice];
    
    // _eraseDestinationDevice = NO;
    
    if (filesystem == NULL) {
        _filesystem = FilesystemFAT32;
    } else {
        _filesystem = filesystem;
    }
    
    return self;
}

@end
