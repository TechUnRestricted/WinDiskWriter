//
//  DiskWriter.m
//  windiskwriter
//
//  Created by Macintosh on 26.01.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSFileManager+Common.h"
#import "DWFilesContainer.h"
#import "HelperFunctions.h"
#import "NSString+Common.h"
#import "WimlibWrapper.h"
#import "DiskManager.h"
#import "Filesystems.h"
#import "DiskWriter.h"
#import "BootModes.h"
#import "constants.h"
#import "HDIUtil.h"

const uint32_t FAT32_MAX_FILE_SIZE = UINT32_MAX;

@implementation DiskWriter {
    NSFileManager *localFileManager;
}

- (instancetype _Nonnull)initWithDWFilesContainer: (DWFilesContainer * _Nonnull)filesContainer
                                  destinationPath: (NSString * _Nonnull)destinationPath
                                         bootMode: (BootMode _Nonnull)bootMode
                            destinationFilesystem: (Filesystem _Nonnull)destinationFilesystem {
    localFileManager = [NSFileManager defaultManager];
    
    _filesContainer = filesContainer;
    _destinationPath = destinationPath;
    _bootMode = bootMode;
    _destinationFilesystem = _destinationFilesystem;
    
    return self;
}

- (BOOL)commonErrorCheckerWithError: (NSError *_Nonnull *_Nonnull)error {
    /* Currently unsupported option */
    if (_bootMode != BootModeUEFI) {
        *error = [NSError errorWithDomain: PACKAGE_NAME
                                     code: DWErrorCodeUnsupportedBootMode
                                 userInfo: @{DEFAULT_ERROR_KEY: @"Legacy Boot Mode is not supported yet."}];
        
        return NO;
    }
    
    if (![localFileManager folderExistsAtPath: _destinationPath]) {
        *error = [NSError errorWithDomain: PACKAGE_NAME
                                     code: DWErrorCodeDestinationPathDoesNotExist
                                 userInfo: @{DEFAULT_ERROR_KEY: @"Destination Path does not exist."}];
        
        return NO;
    }
    
    UInt64 sizeOfSourceFiles = [_filesContainer sizeOfFiles];
    
    NSError *destinationGetDiskAvailableSpaceError = NULL;
    UInt64 destinationDiskAvailableSpace = [self destinationDiskFreeSpace];
    
    if (destinationDiskAvailableSpace == 0) {
        *error = [NSError errorWithDomain: PACKAGE_NAME
                                     code: DWErrorCodeGetDiskAvailableSpaceFailure
                                 userInfo: @{DEFAULT_ERROR_KEY: @"Can't get Destination Disk available space."}];
        return NO;
    }
    
    if (sizeOfSourceFiles > destinationDiskAvailableSpace) {
        *error = [NSError errorWithDomain: PACKAGE_NAME
                                     code: DWErrorCodeSourceIsTooLarge
                                 userInfo: @{DEFAULT_ERROR_KEY: @"Source is too large for the Destination Disk."}];
        return NO;
    }
}

- (UInt64)destinationDiskFreeSpace {
    NSDictionary *filesystemAttributes = [localFileManager attributesOfFileSystemForPath: _destinationPath
                                                                                   error: NULL];
    
    return [[filesystemAttributes objectForKey: NSFileSystemFreeSize] longLongValue];
}

- (BOOL)commonWriteWithError: (NSError *_Nonnull *_Nonnull)error
                    callback: (DWCallback _Nonnull)callback {
    if ([self commonErrorCheckerWithError:&error]) {
        return NO;
    }
    
    for (DWFile *currentFile in [_filesContainer files]) {
        NSString *absoluteSourcePath = [_filesContainer.containerPath stringByAppendingPathComponent:currentFile.sourcePath];
        NSString *absoluteDestinationPath = [_destinationPath stringByAppendingPathComponent:currentFile.sourcePath];
        
        if ([localFileManager fileExistsAtPath:absoluteDestinationPath]) {
            DWCallbackHandler(callback, currentFile, DWMessageEntityAlreadyExists);
            continue;
        }
        
        /* Current entity type is Directory */
        if (currentFile.fileType == NSFileTypeDirectory) {
            DWCallbackHandler(callback, currentFile, DWMessageCreateDirectoryProcess);
            
            NSError *createDirectoryError = NULL;
            BOOL directoryCreateSuccess = [localFileManager createDirectoryAtPath: absoluteDestinationPath
                                                      withIntermediateDirectories: YES
                                                                       attributes: NULL
                                                                            error: &createDirectoryError];
            
            DWCallbackHandler(callback, currentFile, (createDirectoryError == NULL ?
                                                      DWMessageCreateDirectorySuccess : DWMessageCreateDirectoryFailure));
            
            continue;
        }
        
        /* Current entity type is File (or something) */
        DWCallbackHandler(callback, currentFile, DWMessageWriteFileProcess);
        
        if (_destinationFilesystem == FilesystemFAT32) {
            NSString *filePathExtension = [[currentFile.sourcePath lowercaseString] pathExtension];
            
            DWCallbackHandler(callback, currentFile, DWMessageSplitWindowsImageProcess);
            
            if ([filePathExtension isEqualToString:@"wim"]) {
                WimlibWrapper *wimlibWrapper = [[WimlibWrapper alloc] initWithWimPath: [currentFile sourcePath]];
                enum wimlib_error_code wimSplitResult =
                [wimlibWrapper splitWithDestinationDirectoryPath: [absoluteSourcePath stringByDeletingLastPathComponent]
                                             maxSliceSizeInBytes: FAT32_MAX_FILE_SIZE / 2
                                                 progressHandler: NULL
                                                         context: NULL];
                
                DWCallbackHandler(callback, currentFile,
                                  (wimSplitResult == WIMLIB_ERR_SUCCESS ?
                                   DWMessageSplitWindowsImageSuccess : DWMessageSplitWindowsImageFailure));
            } else if ([filePathExtension isEqualToString:@"esd"]) {
                DWCallbackHandler(callback, currentFile, DWMessageUnsupportedOperation);
            } else {
                DWCallbackHandler(callback, currentFile, DWMessageFileIsTooLarge);
            }
            
            continue;
        }
        
        DWCallbackHandler(callback, currentFile, DWMessageWriteFileProcess);
        if (![localFileManager fileExistsAtPath: absoluteDestinationPath]) {
            NSError *copyFileError = NULL;
            BOOL copyWasSuccessful = [localFileManager copyItemAtPath: absoluteSourcePath
                                                               toPath: absoluteDestinationPath
                                                                error: &copyFileError
            ];
            DWCallbackHandler(callback, currentFile, (copyWasSuccessful ? DWMessageWriteFileSuccess : DWMessageWriteFileFailure));
        } else {
            DWCallbackHandler(callback, currentFile, DWMessageEntityAlreadyExists);
        }
    }
 
/* Called from DWCallbackHandler macro; TODO: Find a better solution. */
quitLoop:
    return YES;
    
}

- (BOOL)writeWindows_8_10_ISOWithError: (NSError *_Nonnull *_Nonnull)error
                              callback: (DWCallback _Nonnull)callback {
    
    return [self commonWriteWithError: &error
                             callback: callback];
}

+ (BOOL)writeWindows11ISOWithSourceDWFilesContainer: (DWFilesContainer * _Nonnull)filesContainer
                                    destinationPath: (NSString * _Nonnull)destinationPath
                 bypassTPMAndSecureBootRequirements: (BOOL)bypassTPMAndSecureBootRequirements
                                           bootMode: (BootMode _Nonnull)bootMode
                              destinationFilesystem: (Filesystem _Nonnull)filesystem
                                              error: (NSError *_Nonnull *_Nonnull)error
                                 progressController: (DWCallback _Nonnull)progressController {
    
    
    
    
    
    return YES;
}

@end
