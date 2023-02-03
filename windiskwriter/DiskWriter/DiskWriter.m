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
#import "wimlib.h"

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
    
    if ([destinationDeviceDM getDiskInfo].BSDName == NULL) {
        DebugLog(@"The specified destination device is invalid.");
    }
    
    return destinationDeviceDM;
}

static enum wimlib_progress_status extractProgress(enum wimlib_progress_msg msg,
                                                   union wimlib_progress_info *info,
                                                   void *progctx) {
    /*
     WIMLIB_PROGRESS_MSG_SPLIT_BEGIN_PART
     WIMLIB_PROGRESS_MSG_WRITE_STREAMS
     
     WIMLIB_PROGRESS_MSG_SPLIT_END_PART
     WIMLIB_PROGRESS_MSG_SPLIT_BEGIN_PART
     WIMLIB_PROGRESS_MSG_WRITE_STREAMS
     
     WIMLIB_PROGRESS_MSG_WRITE_METADATA_BEGIN
     WIMLIB_PROGRESS_MSG_WRITE_METADATA_END
     
     WIMLIB_PROGRESS_MSG_SPLIT_END_PART
     */

    switch (msg) {
            
        case WIMLIB_PROGRESS_MSG_EXTRACT_IMAGE_BEGIN:
            NSLog(@"WIMLIB_PROGRESS_MSG_EXTRACT_IMAGE_BEGIN");
            break;
        case WIMLIB_PROGRESS_MSG_EXTRACT_TREE_BEGIN:
            NSLog(@"WIMLIB_PROGRESS_MSG_EXTRACT_TREE_BEGIN");
            break;
        case WIMLIB_PROGRESS_MSG_EXTRACT_FILE_STRUCTURE:
            NSLog(@"WIMLIB_PROGRESS_MSG_EXTRACT_FILE_STRUCTURE");
            break;
        case WIMLIB_PROGRESS_MSG_EXTRACT_STREAMS:
            NSLog(@"WIMLIB_PROGRESS_MSG_EXTRACT_STREAMS");
            break;
        case WIMLIB_PROGRESS_MSG_EXTRACT_SPWM_PART_BEGIN:
            NSLog(@"WIMLIB_PROGRESS_MSG_EXTRACT_SPWM_PART_BEGIN");
            break;
        case WIMLIB_PROGRESS_MSG_EXTRACT_METADATA:
            NSLog(@"WIMLIB_PROGRESS_MSG_EXTRACT_METADATA");
            break;
        case WIMLIB_PROGRESS_MSG_EXTRACT_IMAGE_END:
            NSLog(@"WIMLIB_PROGRESS_MSG_EXTRACT_IMAGE_END");
            break;
        case WIMLIB_PROGRESS_MSG_EXTRACT_TREE_END:
            NSLog(@"WIMLIB_PROGRESS_MSG_EXTRACT_TREE_END");
            break;
        case WIMLIB_PROGRESS_MSG_SCAN_BEGIN:
            NSLog(@"WIMLIB_PROGRESS_MSG_SCAN_BEGIN");
            break;
        case WIMLIB_PROGRESS_MSG_SCAN_DENTRY:
            NSLog(@"WIMLIB_PROGRESS_MSG_SCAN_DENTRY");
            break;
        case WIMLIB_PROGRESS_MSG_SCAN_END:
            NSLog(@"WIMLIB_PROGRESS_MSG_SCAN_END");
            break;
        case WIMLIB_PROGRESS_MSG_WRITE_STREAMS:
            NSLog(@"WIMLIB_PROGRESS_MSG_WRITE_STREAMS");
            break;
        case WIMLIB_PROGRESS_MSG_WRITE_METADATA_BEGIN:
            NSLog(@"WIMLIB_PROGRESS_MSG_WRITE_METADATA_BEGIN");
            break;
        case WIMLIB_PROGRESS_MSG_WRITE_METADATA_END:
            NSLog(@"WIMLIB_PROGRESS_MSG_WRITE_METADATA_END");
            break;
        case WIMLIB_PROGRESS_MSG_RENAME:
            NSLog(@"WIMLIB_PROGRESS_MSG_RENAME");
            break;
        case WIMLIB_PROGRESS_MSG_VERIFY_INTEGRITY:
            NSLog(@"WIMLIB_PROGRESS_MSG_VERIFY_INTEGRITY");
            break;
        case WIMLIB_PROGRESS_MSG_CALC_INTEGRITY:
            NSLog(@"WIMLIB_PROGRESS_MSG_CALC_INTEGRITY");
            break;
        case WIMLIB_PROGRESS_MSG_SPLIT_BEGIN_PART:
            NSLog(@"WIMLIB_PROGRESS_MSG_SPLIT_BEGIN_PART");
            break;
        case WIMLIB_PROGRESS_MSG_SPLIT_END_PART:
            NSLog(@"WIMLIB_PROGRESS_MSG_SPLIT_END_PART");
            break;
        case WIMLIB_PROGRESS_MSG_UPDATE_BEGIN_COMMAND:
            NSLog(@"WIMLIB_PROGRESS_MSG_UPDATE_BEGIN_COMMAND");
            break;
        case WIMLIB_PROGRESS_MSG_UPDATE_END_COMMAND:
            NSLog(@"WIMLIB_PROGRESS_MSG_UPDATE_END_COMMAND");
            break;
        case WIMLIB_PROGRESS_MSG_REPLACE_FILE_IN_WIM:
            NSLog(@"WIMLIB_PROGRESS_MSG_REPLACE_FILE_IN_WIM");
            break;
        case WIMLIB_PROGRESS_MSG_WIMBOOT_EXCLUDE:
            NSLog(@"WIMLIB_PROGRESS_MSG_WIMBOOT_EXCLUDE");
            break;
        case WIMLIB_PROGRESS_MSG_UNMOUNT_BEGIN:
            NSLog(@"WIMLIB_PROGRESS_MSG_UNMOUNT_BEGIN");
            break;
        case WIMLIB_PROGRESS_MSG_DONE_WITH_FILE:
            NSLog(@"WIMLIB_PROGRESS_MSG_DONE_WITH_FILE");
            break;
        case WIMLIB_PROGRESS_MSG_BEGIN_VERIFY_IMAGE:
            NSLog(@"WIMLIB_PROGRESS_MSG_BEGIN_VERIFY_IMAGE");
            break;
        case WIMLIB_PROGRESS_MSG_END_VERIFY_IMAGE:
            NSLog(@"WIMLIB_PROGRESS_MSG_END_VERIFY_IMAGE");
            break;
        case WIMLIB_PROGRESS_MSG_VERIFY_STREAMS:
            NSLog(@"WIMLIB_PROGRESS_MSG_VERIFY_STREAMS");
            break;
        case WIMLIB_PROGRESS_MSG_TEST_FILE_EXCLUSION:
            NSLog(@"WIMLIB_PROGRESS_MSG_TEST_FILE_EXCLUSION");
            break;
        case WIMLIB_PROGRESS_MSG_HANDLE_ERROR:
            NSLog(@"WIMLIB_PROGRESS_MSG_HANDLE_ERROR");
            break;
    }

    return WIMLIB_PROGRESS_STATUS_CONTINUE;
}

+ (enum wimlib_error_code)splitWIMWithOriginFilePath: (NSString *)originWIMFilePath
            destinationWIMFilePath: (NSString *)destinationWIMFilePath
               maxSliceSizeInBytes: (uint64_t *)maxSliceSizeInBytes{
    WIMStruct *currentWIM;
    
    enum wimlib_error_code wimOpenReturn = wimlib_open_wim([originWIMFilePath UTF8String], 0, &currentWIM);
    wimlib_register_progress_function(currentWIM, extractProgress, NULL);
   
    NSString *destinationFileName = [[[originWIMFilePath lastPathComponent] stringByDeletingPathExtension] stringByAppendingPathExtension:@"swm"];
    
    enum wimlib_error_code splitResultReturn = wimlib_split(currentWIM, [destinationFileName UTF8String], maxSliceSizeInBytes, NULL);
    
    wimlib_free(currentWIM);
    
    return splitResultReturn;
}

+ (BOOL)writeWindows11ISOWithSourcePath: (NSString *)sourcePath
                        destinationPath: (NSString *)destinationPath
                  bypassTPMRequirements: (BOOL)bypassTPMAndSecureBootRequirements
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
        
        /* WIM Handler */
        if (isFAT32 && [currentFileAttributes fileSize] > FAT32_MAX_FILE_SIZE) {
            NSString *filePathExtension = [[sourceFilePath lowercaseString] pathExtension];
            
            if ([filePathExtension isEqualToString: @"wim"]) {
                // TODO: Implement .wim file splitting
                enum wimlib_error_code wimSplitResult = [DiskWriter splitWIMWithOriginFilePath: sourceFilePath
                                                                        destinationWIMFilePath: [destinationPasteFilePath stringByDeletingLastPathComponent] maxSliceSizeInBytes: 1500000000
                ];
                
                
                
                DebugLog(@"Splitting the .wim image for several parts was %@.",
                         (wimSplitResult == WIMLIB_ERR_SUCCESS ? @"successful" : @"unsuccesful")
                );
                
                if (wimSplitResult != WIMLIB_ERR_SUCCESS) {
                    return NO;
                }
                
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
