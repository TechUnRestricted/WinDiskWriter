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
#import "constants.h"

const uint32_t FAT32_MAX_FILE_SIZE = 4294967295;

@implementation DiskWriter


static enum wimlib_progress_status extractProgress(enum wimlib_progress_msg msg,
                                                   union wimlib_progress_info *info,
                                                   void *progctx) {
    
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

+ (BOOL)writeWindows11ISOWithSourcePath: (NSString * _Nonnull)sourcePath
                        destinationPath: (NSString * _Nonnull)destinationPath
     bypassTPMAndSecureBootRequirements: (BOOL)bypassTPMAndSecureBootRequirements
                               bootMode: (BootMode _Nonnull)bootMode
                                isFAT32: (BOOL)isFAT32 // TODO: Come up with a more elegant solution
                                  error: (NSError **)error
                     progressController: (FileWriteResult _Nullable)progressController
{
    
    if (bootMode == BootModeLegacy) {
        if (error != NULL) {
            *error = [NSError errorWithDomain: packageName
                                         code: -1
                                     userInfo: @"Legacy Boot Mode is not supported yet."];
        }
        
        return NO;
    }
    
    NSFileManager *localFileManager = [NSFileManager defaultManager];
    if (![localFileManager folderExistsAtPath: sourcePath]) {
        if (error != NULL) {
            *error = [NSError errorWithDomain: packageName
                                         code: -2
                                     userInfo: @"Source Path does not exist."];
        }
        
        return NO;
    }
    
    if (![localFileManager folderExistsAtPath: destinationPath]) {
        if (error != NULL) {
            *error = [NSError errorWithDomain: packageName
                                         code: -3
                                     userInfo: @"Destination Path does not exist."];
        }
        
        return NO;
    }
    
    NSError *entityEnumerationError = NULL;
    NSDirectoryEnumerator *entityEnumeration = [localFileManager subpathsOfDirectoryAtPath: sourcePath
                                                                                     error: &entityEnumerationError];
    
    if (entityEnumerationError != NULL) {
        if (error != NULL) {
            *error = [NSError errorWithDomain: packageName
                                         code: -4
                                     userInfo: @"Can't enumerate entites in the specified source path."];
        }
        
        return NO;
    }
    
    uint64_t filesCopied = 0;
    uint64_t sourceFilesCount = [(NSArray *)entityEnumeration count];
    
    for (NSString *sourceEntityRelativePath in entityEnumeration) {
        struct FileWriteInfo fileWriteInfo;
        fileWriteInfo.sourceFilePath = [sourcePath stringByAppendingPathComponent: sourceEntityRelativePath];
        fileWriteInfo.destinationFilePath = [destinationPath stringByAppendingPathComponent: sourceEntityRelativePath];
        
        fileWriteInfo.entitiesRemain = sourceFilesCount - ++filesCopied;
        fileWriteInfo.message = DWMessageFailure;
        
        BOOL isDirectory;
        [localFileManager fileExistsAtPath: fileWriteInfo.sourceFilePath
                               isDirectory: &isDirectory];
        
        if (isDirectory) {
            NSError *createDirectoryError;
            BOOL directoryCreated = [localFileManager createDirectoryAtPath: fileWriteInfo.destinationFilePath
                                                withIntermediateDirectories: YES
                                                                 attributes: NULL
                                                                      error: &createDirectoryError];
            
            if (createDirectoryError == NULL) {
                fileWriteInfo.message = DWMessageSuccess;
            }
        } else {
            NSError *getFileAttributesError;
            NSDictionary *currentFileAttributes = [localFileManager attributesOfItemAtPath: fileWriteInfo.sourceFilePath
                                                                                     error: &getFileAttributesError];
            
            if (getFileAttributesError != NULL) {
                fileWriteInfo.message = DWMessageCantGetFileAttributes;
            }
            else if (isFAT32 && [currentFileAttributes fileSize] > FAT32_MAX_FILE_SIZE) {
                NSString *filePathExtension = [[fileWriteInfo.sourceFilePath lowercaseString] pathExtension];
                
                if ([filePathExtension isEqualToString: @"wim"]) {
                    enum wimlib_error_code wimSplitResult = [DiskWriter splitWIMWithOriginFilePath: fileWriteInfo.sourceFilePath
                                                                            destinationWIMFilePath: [fileWriteInfo.destinationFilePath stringByDeletingLastPathComponent]
                                                                               maxSliceSizeInBytes: 1500000000
                    ];
                    
                    if (wimSplitResult == WIMLIB_ERR_SUCCESS) {
                        fileWriteInfo.message = DWMessageSuccess;
                    }
                    
                } else if ([filePathExtension isEqualToString:@"esd"]) {
                    // TODO: Implement .esd file splitting
                    fileWriteInfo.message = DWMessageUnsupportedOperation;
                } else {
                    fileWriteInfo.message = DWMessageFileIsTooLarge;
                }
            } else {
                NSError *copyFileError;
                BOOL fileCopied = [localFileManager copyItemAtPath: fileWriteInfo.sourceFilePath
                                                            toPath: fileWriteInfo.destinationFilePath
                                                             error: &copyFileError
                ];
                
                if (fileCopied) {
                    fileWriteInfo.message = DWMessageSuccess;
                }
            }
        }
        
        /*
         * Stopping the writing process if:
         * - The callback function was not passed to the parameters and
         * - Сopying the last file was not successful
         * Or:
         * - The callback function returned NO
         */
        
        if (progressController == NULL && (fileWriteInfo.message != DWMessageSuccess)) {
            return NO;
        } else if (!progressController(fileWriteInfo)) {
            return NO;
        }
        
    }
    return YES;
}

@end
