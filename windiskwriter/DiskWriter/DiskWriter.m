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
#import "BootModes.h"
#import "HelperFunctions.h"
#import "NSString+Common.h"
#import "NSFileManager+Common.h"
#import "wimlib.h"

const uint32_t FAT32_MAX_FILE_SIZE = 4294967295;

@implementation DiskWriter


static enum wimlib_progress_status extractProgress(enum wimlib_progress_msg msg,
                                                   union wimlib_progress_info *info,
                                                   void *progctx) {
    switch (msg) {
        case WIMLIB_PROGRESS_MSG_EXTRACT_IMAGE_BEGIN:
            DebugLog(@"WIMLIB_PROGRESS_MSG_EXTRACT_IMAGE_BEGIN");
            break;
        case WIMLIB_PROGRESS_MSG_EXTRACT_TREE_BEGIN:
            DebugLog(@"WIMLIB_PROGRESS_MSG_EXTRACT_TREE_BEGIN");
            break;
        case WIMLIB_PROGRESS_MSG_EXTRACT_FILE_STRUCTURE:
            DebugLog(@"WIMLIB_PROGRESS_MSG_EXTRACT_FILE_STRUCTURE");
            break;
        case WIMLIB_PROGRESS_MSG_EXTRACT_STREAMS:
            DebugLog(@"WIMLIB_PROGRESS_MSG_EXTRACT_STREAMS");
            break;
        case WIMLIB_PROGRESS_MSG_EXTRACT_SPWM_PART_BEGIN:
            DebugLog(@"WIMLIB_PROGRESS_MSG_EXTRACT_SPWM_PART_BEGIN");
            break;
        case WIMLIB_PROGRESS_MSG_EXTRACT_METADATA:
            DebugLog(@"WIMLIB_PROGRESS_MSG_EXTRACT_METADATA");
            break;
        case WIMLIB_PROGRESS_MSG_EXTRACT_IMAGE_END:
            DebugLog(@"WIMLIB_PROGRESS_MSG_EXTRACT_IMAGE_END");
            break;
        case WIMLIB_PROGRESS_MSG_EXTRACT_TREE_END:
            DebugLog(@"WIMLIB_PROGRESS_MSG_EXTRACT_TREE_END");
            break;
        case WIMLIB_PROGRESS_MSG_SCAN_BEGIN:
            DebugLog(@"WIMLIB_PROGRESS_MSG_SCAN_BEGIN");
            break;
        case WIMLIB_PROGRESS_MSG_SCAN_DENTRY:
            DebugLog(@"WIMLIB_PROGRESS_MSG_SCAN_DENTRY");
            break;
        case WIMLIB_PROGRESS_MSG_SCAN_END:
            DebugLog(@"WIMLIB_PROGRESS_MSG_SCAN_END");
            break;
        case WIMLIB_PROGRESS_MSG_WRITE_STREAMS:
            DebugLog(@"WIMLIB_PROGRESS_MSG_WRITE_STREAMS");
            break;
        case WIMLIB_PROGRESS_MSG_WRITE_METADATA_BEGIN:
            DebugLog(@"WIMLIB_PROGRESS_MSG_WRITE_METADATA_BEGIN");
            break;
        case WIMLIB_PROGRESS_MSG_WRITE_METADATA_END:
            DebugLog(@"WIMLIB_PROGRESS_MSG_WRITE_METADATA_END");
            break;
        case WIMLIB_PROGRESS_MSG_RENAME:
            DebugLog(@"WIMLIB_PROGRESS_MSG_RENAME");
            break;
        case WIMLIB_PROGRESS_MSG_VERIFY_INTEGRITY:
            DebugLog(@"WIMLIB_PROGRESS_MSG_VERIFY_INTEGRITY");
            break;
        case WIMLIB_PROGRESS_MSG_CALC_INTEGRITY:
            DebugLog(@"WIMLIB_PROGRESS_MSG_CALC_INTEGRITY");
            break;
        case WIMLIB_PROGRESS_MSG_SPLIT_BEGIN_PART:
            DebugLog(@"WIMLIB_PROGRESS_MSG_SPLIT_BEGIN_PART");
            break;
        case WIMLIB_PROGRESS_MSG_SPLIT_END_PART:
            DebugLog(@"WIMLIB_PROGRESS_MSG_SPLIT_END_PART");
            break;
        case WIMLIB_PROGRESS_MSG_UPDATE_BEGIN_COMMAND:
            DebugLog(@"WIMLIB_PROGRESS_MSG_UPDATE_BEGIN_COMMAND");
            break;
        case WIMLIB_PROGRESS_MSG_UPDATE_END_COMMAND:
            DebugLog(@"WIMLIB_PROGRESS_MSG_UPDATE_END_COMMAND");
            break;
        case WIMLIB_PROGRESS_MSG_REPLACE_FILE_IN_WIM:
            DebugLog(@"WIMLIB_PROGRESS_MSG_REPLACE_FILE_IN_WIM");
            break;
        case WIMLIB_PROGRESS_MSG_WIMBOOT_EXCLUDE:
            DebugLog(@"WIMLIB_PROGRESS_MSG_WIMBOOT_EXCLUDE");
            break;
        case WIMLIB_PROGRESS_MSG_UNMOUNT_BEGIN:
            DebugLog(@"WIMLIB_PROGRESS_MSG_UNMOUNT_BEGIN");
            break;
        case WIMLIB_PROGRESS_MSG_DONE_WITH_FILE:
            DebugLog(@"WIMLIB_PROGRESS_MSG_DONE_WITH_FILE");
            break;
        case WIMLIB_PROGRESS_MSG_BEGIN_VERIFY_IMAGE:
            DebugLog(@"WIMLIB_PROGRESS_MSG_BEGIN_VERIFY_IMAGE");
            break;
        case WIMLIB_PROGRESS_MSG_END_VERIFY_IMAGE:
            DebugLog(@"WIMLIB_PROGRESS_MSG_END_VERIFY_IMAGE");
            break;
        case WIMLIB_PROGRESS_MSG_VERIFY_STREAMS:
            DebugLog(@"WIMLIB_PROGRESS_MSG_VERIFY_STREAMS");
            break;
        case WIMLIB_PROGRESS_MSG_TEST_FILE_EXCLUSION:
            DebugLog(@"WIMLIB_PROGRESS_MSG_TEST_FILE_EXCLUSION");
            break;
        case WIMLIB_PROGRESS_MSG_HANDLE_ERROR:
            DebugLog(@"WIMLIB_PROGRESS_MSG_HANDLE_ERROR");
            break;
    }
    
    return WIMLIB_PROGRESS_STATUS_CONTINUE;
}

+ (enum wimlib_error_code)splitWIMWithOriginFilePath: (NSString * _Nonnull)originWIMFilePath
                              destinationWIMFilePath: (NSString * _Nonnull)destinationWIMFilePath
                                 maxSliceSizeInBytes: (uint64_t * _Nonnull)maxSliceSizeInBytes{
    WIMStruct *currentWIM;
    
    enum wimlib_error_code wimOpenReturn = wimlib_open_wim([originWIMFilePath UTF8String], 0, &currentWIM);
    wimlib_register_progress_function(currentWIM, extractProgress, NULL);
    
    NSString *destinationFileName = [[[originWIMFilePath lastPathComponent] stringByDeletingPathExtension] stringByAppendingPathExtension:@"swm"];
    
    enum wimlib_error_code splitResultReturn = wimlib_split(currentWIM, [[destinationWIMFilePath stringByAppendingPathComponent:destinationFileName] UTF8String], maxSliceSizeInBytes, NULL);
    
    wimlib_free(currentWIM);
    
    return splitResultReturn;
}

+ (BOOL)writeWindowsISOWithSourcePath: (NSString * _Nonnull)sourcePath
                      destinationPath: (NSString * _Nonnull)destinationPath
   bypassTPMAndSecureBootRequirements: (BOOL)bypassTPMAndSecureBootRequirements
                             bootMode: (BootMode)bootMode
                              isFAT32: (BOOL)isFAT32 { // TODO: Come up with a more elegant solution
    
    if (bootMode == BootModeLegacy) {
        DebugLog(@"Legacy Boot Mode is not supported yet.");
        return NO;
    }
    
    NSFileManager *localFileManager = [NSFileManager defaultManager];
    if (![localFileManager folderExistsAtPath: sourcePath]) {
        DebugLog(@"Source Path \"%@\" does not exist.", sourcePath);
        return NO;
    }
    
    if (![localFileManager folderExistsAtPath: destinationPath]) {
        DebugLog(@"Destination Path \"%@\" does not exist.", sourcePath);
        return NO;
    }
    
    NSDirectoryEnumerator *dirEnum = [localFileManager enumeratorAtPath: sourcePath];
    
    NSString *fileName = nil;
    while ((fileName = [dirEnum nextObject])) {
        NSString *sourceFilePath = [sourcePath stringByAppendingPathComponent: fileName];
        NSString *destinationPasteFilePath = [destinationPath stringByAppendingPathComponent: fileName];
        
        BOOL isDirectory;
        [localFileManager fileExistsAtPath: sourceFilePath
                               isDirectory: &isDirectory];
        
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
        NSDictionary *currentFileAttributes = [localFileManager attributesOfItemAtPath: sourceFilePath
                                                                                 error: &getFileAttributesError];
        
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
            
            continue;
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
            continue;
            //return NO;
        }
        
    }
    
    return YES;
}

@end
