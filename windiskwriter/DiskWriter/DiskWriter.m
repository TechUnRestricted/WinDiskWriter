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
#import "HelperFunctions.h"
#import "NSString+Common.h"

const uint32_t FAT32_MAX_FILE_SIZE = 4294967295;

@implementation DiskWriter

+ (NSString * _Nullable)getImageSourceMountPath: (NSString * _Nonnull)isoPath {
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
    if (![[[isoPath lowercaseString] pathExtension] isEqualToString: @"iso"]) {
        DebugLog(@"This file does not have an .iso extension.");
        return NULL;
    }
    
    HDIUtil *hdiutil = [[HDIUtil alloc] initWithImagePath:isoPath];
    if([hdiutil attachImageWithArguments:@[@"-readonly", @"-noverify", @"-noautofsck", @"-noautoopen"]]) {
        return [hdiutil getMountPoint];
    }
    
    return NULL;
}

+ (DiskManager * _Nullable)getDestinationDevice: (NSString *)inputPath {
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    BOOL isDirectory;
    BOOL exists = [fileManager fileExistsAtPath:inputPath isDirectory:&isDirectory];
    
    if (!exists) {
        DebugLog(@"The given Destination path does not exist.");
        return NULL;
    }
    
    DiskManager *destinationDeviceDM;
    
    if ([inputPath hasOneOfThePrefixes:@[
        @"disk", @"/dev/disk",
        @"rdisk", @"/dev/rdisk"
    ]]) {
        DebugLog(@"Received device destination path was defined as BSD Name.");
        destinationDeviceDM = [[DiskManager alloc] initWithBSDName:inputPath];
    }
    else if ([inputPath hasPrefix:@"/Volumes/"]) {
        DebugLog(@"Received device destination path was defined as Mounted Volume.");
        if (@available(macOS 10.7, *)) {
            destinationDeviceDM = [[DiskManager alloc] initWithVolumePath:inputPath];
        } else {
            // TODO: Fix Mac OS X 10.6 Snow Leopard support
            DebugLog(@"Can't load Destination device info from Mounted Volume. Prevented Unsupported API Call. Specify the device using the BSD name."
            );
        }
    }
    
    if (destinationDeviceDM == NULL) {
        
    }
    
    if ([destinationDeviceDM getDiskInfo].BSDName == NULL) {
        DebugLog(@"The specified destination device is invalid.");
    }
    
    return destinationDeviceDM;
}

+ (BOOL)splitWIMWithOriginFilePath: (NSString *)originWIMFilePath
            destinationWIMFilePath: (NSString *)destinationWIMFilePath {
    
}

+ (BOOL)writeWindows11ISOWithSourcePath: (NSString *)sourcePath
                        destinationPath: (NSString *)destinationPath
                  bypassTPMRequirements: (BOOL)bypassTPMRequirements
                                isFAT32: (BOOL)isFAT32 { // TODO: Come up with a more elegant solution
    
    NSFileManager *localFileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *dirEnum = [localFileManager enumeratorAtPath:sourcePath];
        
    NSString *fileName = nil;
    while ((fileName = [dirEnum nextObject])) {
        NSString *sourceFilePath = [sourcePath stringByAppendingPathComponent:fileName];
        NSString *destinationPasteFilePath = [destinationPath stringByAppendingPathComponent:fileName];
        
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
        
        if (isFAT32 && [currentFileAttributes fileSize] > FAT32_MAX_FILE_SIZE /* destinationDiskInfo.mediaKind */) {
            NSString *filePathExtension = [[sourceFilePath lowercaseString] pathExtension];
            
            if ([filePathExtension isEqualToString: @"wim"]) {
                // TODO: Implement .wim file splitting
                BOOL wimSplitSuccessful = [DiskWriter splitWIMWithOriginFilePath:sourceFilePath
                                                          destinationWIMFilePath:[destinationPasteFilePath stringByDeletingLastPathComponent]];
                // DebugLog(<#...#>)
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
    
    return YES;
}

@end
