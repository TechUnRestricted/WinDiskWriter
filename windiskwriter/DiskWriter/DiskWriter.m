//
//  DiskWriter.m
//  windiskwriter
//
//  Created by Macintosh on 26.01.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSFileManager+Common.h"
#import "HelperFunctions.h"
#import "NSString+Common.h"
#import "DiskManager.h"
#import "Filesystems.h"
#import "DiskWriter.h"
#import "BootModes.h"
#import "constants.h"
#import "HDIUtil.h"
#import "wimlib.h"

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
                                  error: (NSError *_Nullable *_Nullable)error
                     progressController: (FileWriteResult _Nullable)progressController
{
    
    if (bootMode == BootModeLegacy) {
        if (error != NULL) {
            *error = [NSError errorWithDomain: PACKAGE_NAME
                                         code: -1
                                     userInfo: @{DEFAULT_ERROR_KEY: @"Legacy Boot Mode is not supported yet."}];
        }
        
        return NO;
    }
    
    NSFileManager *localFileManager = [NSFileManager defaultManager];
    if (![localFileManager folderExistsAtPath: sourcePath]) {
        if (error != NULL) {
            *error = [NSError errorWithDomain: PACKAGE_NAME
                                         code: -2
                                     userInfo: @{DEFAULT_ERROR_KEY: @"Source Path does not exist."}];
        }
        
        return NO;
    }
    
    if (![localFileManager folderExistsAtPath: destinationPath]) {
        if (error != NULL) {
            *error = [NSError errorWithDomain: PACKAGE_NAME
                                         code: -3
                                     userInfo: @{DEFAULT_ERROR_KEY: @"Destination Path does not exist."}];
        }
        
        return NO;
    }
    
    if (progressController == NULL) {
    }
    
    NSError *entityEnumerationError = NULL;
    NSDirectoryEnumerator *entityEnumeration = [localFileManager subpathsOfDirectoryAtPath: sourcePath
                                                                                     error: &entityEnumerationError];
    
    if (entityEnumerationError != NULL) {
        if (error != NULL) {
            *error = [NSError errorWithDomain: PACKAGE_NAME
                                         code: -4
                                     userInfo: @{DEFAULT_ERROR_KEY: @"Can't enumerate entites in the specified source path."}];
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
        
        /*
         *************************************************************
         * We determine whether the current entity is a folder.      *
         * If it is a folder, then create it on the destination disk *
         * (Necessary in order to copy each file individually, not   *
         * the entire directory at once)                             *
         *************************************************************
         */
        
        BOOL isDirectory;
        [localFileManager fileExistsAtPath: fileWriteInfo.sourceFilePath
                               isDirectory: &isDirectory];
        
        if (isDirectory) {
            if (!progressController(fileWriteInfo, DWMessageCreateDirectoryProcess)) {
                return NO;
            }
            
            NSError *createDirectoryError;
            BOOL directoryCreated = [localFileManager createDirectoryAtPath: fileWriteInfo.destinationFilePath
                                                withIntermediateDirectories: YES
                                                                 attributes: NULL
                                                                      error: &createDirectoryError];
            
            if (!progressController(fileWriteInfo, (directoryCreated ? DWMessageCreateDirectorySuccess : DWMessageCreateDirectoryFailure))) {
                return NO;
            }
            continue;
        }
        
        if (!progressController(fileWriteInfo, DWMessageGetFileAttributesProcess)) {
            return NO;
        }
        
        /*
         *****************************************************
         * We get a list of attributes for the current file. *
         * It is necessary to determine its size.            *
         *****************************************************
         */
        
        NSError *getFileAttributesError;
        NSDictionary *currentFileAttributes = [localFileManager attributesOfItemAtPath: fileWriteInfo.sourceFilePath
                                                                                 error: &getFileAttributesError];
        
        if (getFileAttributesError == NULL) {
            if (!progressController(fileWriteInfo, DWMessageGetFileAttributesSuccess)) {
                return NO;
            }
        } else {
            if (!progressController(fileWriteInfo, DWMessageGetFileAttributesFailure)) {
                return NO;
            }
            continue;
        }
        
        /*
         ******************************************************************
         * If the file system of the destination device is FAT32,         *
         * we need to check the possibilities of circumventing the limits *
         * of the maximum file size [>4GB] (if possible).                 *
         ******************************************************************
         */
        
        if (isFAT32 && [currentFileAttributes fileSize] > FAT32_MAX_FILE_SIZE) {
            NSString *filePathExtension = [[fileWriteInfo.sourceFilePath lowercaseString] pathExtension];
            
            /* At the moment , separation is only possible for .wim files */
            if ([filePathExtension isEqualToString: @"wim"]) {
                continue;
                if (!progressController(fileWriteInfo, DWMessageSplitWindowsImageProcess)) {
                    return NO;
                }
                
                enum wimlib_error_code wimSplitResult = [DiskWriter splitWIMWithOriginFilePath: fileWriteInfo.sourceFilePath
                                                                        destinationWIMFilePath: [fileWriteInfo.destinationFilePath stringByDeletingLastPathComponent]
                                                                           maxSliceSizeInBytes: 1500000000
                ];
                
                if (!progressController(fileWriteInfo, (wimSplitResult == WIMLIB_ERR_SUCCESS ? DWMessageSplitWindowsImageSuccess : DWMessageSplitWindowsImageFailure))) {
                    return NO;
                }
                
            } else if ([filePathExtension isEqualToString: @"esd"]) {
                // TODO: Implement .esd file splitting
                if (!progressController(fileWriteInfo, DWMessageUnsupportedOperation)) {
                    return NO;
                }
            } else {
                if (!progressController(fileWriteInfo, DWMessageFileIsTooLarge)) {
                    return NO;
                }
            }
            continue;
        }
        
        /*
         *****************************************
         * Writing Files to the destination path *
         *****************************************
         */
        
        if (!progressController(fileWriteInfo, DWMessageWriteFileProcess)) {
            return NO;
        }
        
        if (![localFileManager fileExistsAtPath:fileWriteInfo.destinationFilePath]) {
            NSError *copyFileError;
            BOOL copyWasSuccessful = [localFileManager copyItemAtPath: fileWriteInfo.sourceFilePath
                                                               toPath: fileWriteInfo.destinationFilePath
                                                                error: &copyFileError
            ];
            
            if (!progressController(fileWriteInfo, (copyWasSuccessful ? DWMessageWriteFileSuccess : DWMessageWriteFileFailure))) {
                return NO;
            }
        } else {
            if (!progressController(fileWriteInfo, DWMessageEntityAlreadyExists)) {
                return NO;
            }
        }
    }
    return YES;
}

@end
