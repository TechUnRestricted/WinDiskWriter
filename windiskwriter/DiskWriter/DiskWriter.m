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
    _destinationFilesystem = destinationFilesystem;
    
    return self;
}

- (BOOL)commonErrorCheckerWithError: (NSError *_Nonnull *_Nonnull)error {
    /* Currently unsupported option */
    if (_bootMode != BootModeUEFI) {
        *error = [NSError errorWithDomain: PACKAGE_NAME
                                     code: DWErrorCodeUnsupportedBootMode
                                 userInfo: @{NSLocalizedDescriptionKey: @"Legacy Boot Mode is not supported yet."}];
        
        return NO;
    }
    
    if (![localFileManager folderExistsAtPath: _destinationPath]) {
        *error = [NSError errorWithDomain: PACKAGE_NAME
                                     code: DWErrorCodeDestinationPathDoesNotExist
                                 userInfo: @{NSLocalizedDescriptionKey: @"Destination Path does not exist."}];
        
        return NO;
    }
    
    UInt64 sizeOfSourceFiles = [_filesContainer sizeOfFiles];
    
    NSError *destinationGetDiskAvailableSpaceError = NULL;
    UInt64 destinationDiskAvailableSpace = [self destinationDiskFreeSpace];
    
    if (destinationDiskAvailableSpace == 0) {
        *error = [NSError errorWithDomain: PACKAGE_NAME
                                     code: DWErrorCodeGetDiskAvailableSpaceFailure
                                 userInfo: @{NSLocalizedDescriptionKey: @"Can't get Destination Disk available space."}];
        return NO;
    }
    
    if (sizeOfSourceFiles > destinationDiskAvailableSpace) {
        *error = [NSError errorWithDomain: PACKAGE_NAME
                                     code: DWErrorCodeSourceIsTooLarge
                                 userInfo: @{NSLocalizedDescriptionKey: @"Source is too large for the Destination Disk."}];
        return NO;
    }
    
    return YES;
}

- (UInt64)destinationDiskFreeSpace {
    NSDictionary *filesystemAttributes = [localFileManager attributesOfFileSystemForPath: _destinationPath
                                                                                   error: NULL];
    
    return [[filesystemAttributes objectForKey: NSFileSystemFreeSize] longLongValue];
}

- (BOOL)commonWriteWithError: (NSError *_Nonnull *_Nonnull)error
                    callback: (DWCallback _Nonnull)callback {
    if (![self commonErrorCheckerWithError:error]) {
        return NO;
    }
    
    DWFile *bootloaderFile = NULL;
    
    for (DWFile *currentFile in [_filesContainer files]) {
        NSString *absoluteSourcePath = [_filesContainer.containerPath stringByAppendingPathComponent:currentFile.sourcePath];
        NSString *absoluteDestinationPath = [_destinationPath stringByAppendingPathComponent:currentFile.sourcePath];
        
        NSString *lastPathComponent = [[[currentFile sourcePath] lastPathComponent] lowercaseString];
        
        if (([lastPathComponent isEqualToString:@"install.wim"] || [lastPathComponent isEqualToString:@"install.esd"]) && bootloaderFile == NULL) {
            bootloaderFile = currentFile;
        }
        
        if ([localFileManager fileExistsAtPath:absoluteDestinationPath]) {
            DWCallbackLoopHandler(callback, currentFile, DWMessageEntityAlreadyExists);
            continue;
        }
        
        /* Current entity type is Directory */
        if (currentFile.fileType == NSFileTypeDirectory) {
            DWCallbackLoopHandler(callback, currentFile, DWMessageCreateDirectoryProcess);
            
            NSError *createDirectoryError = NULL;
            BOOL directoryCreateSuccess = [localFileManager createDirectoryAtPath: absoluteDestinationPath
                                                      withIntermediateDirectories: YES
                                                                       attributes: NULL
                                                                            error: &createDirectoryError];
            
            DWCallbackLoopHandler(callback, currentFile, (createDirectoryError == NULL ?
                                                      DWMessageCreateDirectorySuccess : DWMessageCreateDirectoryFailure));
            
            continue;
        }
        
        /* Current entity type is File (or something) */
        DWCallbackLoopHandler(callback, currentFile, DWMessageWriteFileProcess);
        
        if (_destinationFilesystem == FilesystemFAT32 && currentFile.size > FAT32_MAX_FILE_SIZE) {
            NSString *filePathExtension = [[currentFile.sourcePath lowercaseString] pathExtension];
            
            DWCallbackLoopHandler(callback, currentFile, DWMessageSplitWindowsImageProcess);
            
            if ([filePathExtension isEqualToString:@"wim"]) {
                UInt8 partsCount = ceil((double)currentFile.size / (double)FAT32_MAX_FILE_SIZE);
                UInt32 maxSliceSize = currentFile.size / partsCount;
                
                WimlibWrapper *wimlibWrapper = [[WimlibWrapper alloc] initWithWimPath: absoluteSourcePath];
                enum wimlib_error_code wimSplitResult =
                [wimlibWrapper splitWithDestinationDirectoryPath: [absoluteDestinationPath stringByDeletingLastPathComponent]
                                             maxSliceSizeInBytes: maxSliceSize
                                                 progressHandler: NULL
                                                         context: NULL];
                
                DWCallbackLoopHandler(callback, currentFile,
                                  (wimSplitResult == WIMLIB_ERR_SUCCESS ?
                                   DWMessageSplitWindowsImageSuccess : DWMessageSplitWindowsImageFailure));
            } else if ([filePathExtension isEqualToString:@"esd"]) {
                DWCallbackLoopHandler(callback, currentFile, DWMessageUnsupportedOperation);
            } else {
                DWCallbackLoopHandler(callback, currentFile, DWMessageFileIsTooLarge);
            }
            
            continue;
        }
        
        if (![localFileManager fileExistsAtPath: absoluteDestinationPath]) {
            NSError *copyFileError = NULL;
            BOOL copyWasSuccessful = [localFileManager copyItemAtPath: absoluteSourcePath
                                                               toPath: absoluteDestinationPath
                                                                error: &copyFileError
            ];
            DWCallbackLoopHandler(callback, currentFile, (copyWasSuccessful ? DWMessageWriteFileSuccess : DWMessageWriteFileFailure));
        } else {
            DWCallbackLoopHandler(callback, currentFile, DWMessageEntityAlreadyExists);
        }
    }
    
    if (bootloaderFile) {
        DWCallbackHandler(callback, bootloaderFile, DWMessageExtractWindowsBootloaderProcess);
        
        NSString *bootloaderAbsolutePath = [[_filesContainer containerPath] stringByAppendingPathComponent:[bootloaderFile sourcePath]];
        BOOL extractionSuccessful = [self extractBootloaderFromInstallFile: bootloaderAbsolutePath];
        
        DWCallbackHandler(callback, bootloaderFile, (extractionSuccessful ? DWMessageExtractWindowsBootloaderSuccess : DWMessageExtractWindowsBootloaderFailure));
    }
    
    return YES;
}

- (BOOL)extractBootloaderFromInstallFile: (NSString *_Nonnull)installFile {
    WimlibWrapper *wimlibWrapper = [[WimlibWrapper alloc] initWithWimPath: installFile];
    
    NSString *bootloaderDestinationDirectory = [_destinationPath stringByAppendingPathComponent: @"efi/boot/"];
    
    BOOL directoryCreationSuccessful = [localFileManager createDirectoryAtPath: bootloaderDestinationDirectory
                                                   withIntermediateDirectories: YES
                                                                    attributes: NULL
                                                                         error: NULL];
    
    if (!directoryCreationSuccessful) {
        return NO;
    }
    
    enum wimlib_error_code extractResult = [wimlibWrapper extractFiles: @[@"/Windows/Boot/EFI/bootmgfw.efi"]
                                                  destinationDirectory: bootloaderDestinationDirectory];
    
    if (extractResult != WIMLIB_ERR_SUCCESS) {
        return NO;
    }
    
    BOOL bootloaderRanamingSuccess = [localFileManager moveItemAtPath: [bootloaderDestinationDirectory stringByAppendingPathComponent: @"bootmgfw.efi"]
                                                               toPath: [bootloaderDestinationDirectory stringByAppendingPathComponent: @"bootx64.efi"]
                                                                error: NULL];
    if (!bootloaderRanamingSuccess) {
        return NO;
    }
    
    return YES;
}


- (BOOL)writeWindows_8_10_ISOWithError: (NSError *_Nonnull *_Nonnull)error
                              callback: (DWCallback _Nonnull)callback {
    
    return [self commonWriteWithError: error
                             callback: callback];
}

@end
