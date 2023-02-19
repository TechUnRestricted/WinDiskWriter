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
#import "WimlibWrapper.h"
#import "DiskManager.h"
#import "Filesystems.h"
#import "DiskWriter.h"
#import "DWFileInfo.h"
#import "BootModes.h"
#import "constants.h"
#import "HDIUtil.h"

const uint32_t FAT32_MAX_FILE_SIZE = UINT32_MAX;

@implementation DiskWriter

static enum wimlib_progress_status extractProgress(enum wimlib_progress_msg msg,
                                                   union wimlib_progress_info *info,
                                                   void *progctx) {
    
    return WIMLIB_PROGRESS_STATUS_CONTINUE;
}

+ (BOOL)writeWindowsVistaTo10WithSourcePath: (NSString * _Nonnull)sourcePath
                            destinationPath: (NSString * _Nonnull)destinationPath
         bypassTPMAndSecureBootRequirements: (BOOL)bypassTPMAndSecureBootRequirements
                                   bootMode: (BootMode _Nonnull)bootMode
                                    isFAT32: (BOOL)isFAT32 // TODO: Come up with a more elegant solution
                                      error: (NSError *_Nullable *_Nullable)error
                         progressController: (FileWriteResult _Nullable)progressController {
    
    
}

+ (BOOL)writeWindows11ISOWithSourcePath: (NSString * _Nonnull)sourcePath
                        destinationPath: (NSString * _Nonnull)destinationPath
     bypassTPMAndSecureBootRequirements: (BOOL)bypassTPMAndSecureBootRequirements
                               bootMode: (BootMode _Nonnull)bootMode
                                isFAT32: (BOOL)isFAT32 // TODO: Come up with a more elegant solution
                                  error: (NSError *_Nullable *_Nullable)error
                     progressController: (FileWriteResult _Nullable)progressController {
    
    if (bootMode == BootModeLegacy) {
        if (error != NULL) {
            *error = [NSError errorWithDomain: PACKAGE_NAME
                                         code: DWErrorCodeUnsupportedBootMode
                                     userInfo: @{DEFAULT_ERROR_KEY: @"Legacy Boot Mode is not supported yet."}];
        }
        
        return NO;
    }
    
    NSFileManager *localFileManager = [NSFileManager defaultManager];
    if (![localFileManager folderExistsAtPath: sourcePath]) {
        if (error != NULL) {
            *error = [NSError errorWithDomain: PACKAGE_NAME
                                         code: DWErrorCodeSourcePathDoesNotExist
                                     userInfo: @{DEFAULT_ERROR_KEY: @"Source Path does not exist."}];
        }
        
        return NO;
    }
    
    if (![localFileManager folderExistsAtPath: destinationPath]) {
        if (error != NULL) {
            *error = [NSError errorWithDomain: PACKAGE_NAME
                                         code: DWErrorCodeDestinationPathDoesNotExist
                                     userInfo: @{DEFAULT_ERROR_KEY: @"Destination Path does not exist."}];
        }
        
        return NO;
    }
    
    NSError *destinationDiskGetAttributesError = NULL;
    NSDictionary *destinationDiskAttributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath: destinationPath
                                                            error: &destinationDiskGetAttributesError];
    
    if (destinationDiskGetAttributesError != NULL) {
        if (error != NULL) {
            *error = [NSError errorWithDomain: PACKAGE_NAME
                                         code: DWErrorCodeDiskAttributesObtainingFailure
                                     userInfo: @{DEFAULT_ERROR_KEY: @"Can't get Destination Disk Attributes."}];
        }
        return NO;
    }
    
    uint64_t destinationDiskSpaceAvailable = [[destinationDiskAttributes objectForKey:NSFileSystemFreeSize] longLongValue];
    
    NSError *entityEnumerationError = NULL;
    NSDirectoryEnumerator *entityEnumeration = [localFileManager subpathsOfDirectoryAtPath: sourcePath
                                                                                     error: &entityEnumerationError];
    
    if (entityEnumerationError != NULL) {
        if (error != NULL) {
            *error = [NSError errorWithDomain: PACKAGE_NAME
                                         code: DWErrorCodeEnumerateSourceFilesFailure
                                     userInfo: @{DEFAULT_ERROR_KEY: @"Can't enumerate entites in the specified source path."}];
        }
        return NO;
    }
    
    NSMutableArray<DWFileInfo *> *filesList = [[NSMutableArray alloc] init];
    uint64_t sourceDirectorySize = 0;
    
    for (NSString *sourceEntityRelativePath in entityEnumeration) {
        DWFileInfo *currentFile = [[DWFileInfo alloc] initWithSourcePath: [sourcePath stringByAppendingPathComponent: sourceEntityRelativePath]
                                                         destinationPath: [destinationPath stringByAppendingPathComponent: sourceEntityRelativePath]];
        
        if (!progressController(currentFile, DWMessageGetFileAttributesProcess)) {
            return NO;
        }
        
        NSError *getFileAttributesError;
        NSDictionary *currentFileAttributes = [localFileManager attributesOfItemAtPath: [currentFile sourcePath]
                                                                                 error: &getFileAttributesError];
        
        if (getFileAttributesError == NULL) {
            if (!progressController(currentFile, DWMessageGetFileAttributesSuccess)) {
                return NO;
            }
        } else {
            if (!progressController(currentFile, DWMessageGetFileAttributesFailure)) {
                return NO;
            }
        }
        
        currentFile.fileType = [currentFileAttributes fileType];
        currentFile.size = [currentFileAttributes fileSize];
                
        sourceDirectorySize += currentFile.size;
        
        [filesList addObject:currentFile];
    }
    
    if (sourceDirectorySize > destinationDiskSpaceAvailable) {
        if (error != NULL) {
            *error = [NSError errorWithDomain: PACKAGE_NAME
                                         code: DWErrorCodeSourceIsTooLarge
                                     userInfo: @{DEFAULT_ERROR_KEY: [NSString stringWithFormat:@"Source Directory is too large (%llu bytes) for the Destination Device (%llu bytes available).",
                                                                     sourceDirectorySize,
                                                                     destinationDiskSpaceAvailable
                                     ]}];
        }
        
        return NO;
    }
    
    uint64_t filesCopied = 0;
    uint64_t sourceFilesCount = [(NSArray *)entityEnumeration count];
    
    for (DWFileInfo *currentFile in filesList) {
        /*
         * We determine whether the current entity is a folder.
         * If it is a folder, then create it on the destination disk
         * (Necessary in order to copy each file individually, not
         * the entire directory at once)
         */
        
        if (currentFile.fileType == NSFileTypeDirectory) {
            if (!progressController(currentFile, DWMessageCreateDirectoryProcess)) {
                return NO;
            }
            
            NSError *createDirectoryError = NULL;
            BOOL directoryCreated = [localFileManager createDirectoryAtPath: [currentFile destinationPath]
                                                withIntermediateDirectories: YES
                                                                 attributes: NULL
                                                                      error: &createDirectoryError];
            
            if (!progressController(currentFile, (directoryCreated ? DWMessageCreateDirectorySuccess : DWMessageCreateDirectoryFailure))) {
                return NO;
            }
            
            continue;
        }
        
        /*
         * If the file system of the destination device is FAT32,
         * we need to check the possibilities of circumventing the limits
         * of the maximum file size [>4GB] (if possible).
         */
        
        if (isFAT32 && currentFile.size > FAT32_MAX_FILE_SIZE) {
            NSString *filePathExtension = [[currentFile.sourcePath lowercaseString] pathExtension];
            
            /* At the moment , separation is only possible for .wim files */
            if ([filePathExtension isEqualToString: @"wim"]) {
                if (!progressController(currentFile, DWMessageSplitWindowsImageProcess)) {
                    return NO;
                }
                
                WimlibWrapper *wimlibWrapper = [[WimlibWrapper alloc] initWithWimPath: [currentFile sourcePath]];
                enum wimlib_error_code wimSplitResult = [wimlibWrapper splitWithDestinationDirectoryPath: [[currentFile destinationPath] stringByDeletingLastPathComponent]
                                                                                     maxSliceSizeInBytes: FAT32_MAX_FILE_SIZE / 2
                                                                                         progressHandler: NULL
                                                                                                 context: NULL];
                
                if (!progressController(currentFile, (wimSplitResult == WIMLIB_ERR_SUCCESS ? DWMessageSplitWindowsImageSuccess : DWMessageSplitWindowsImageFailure))) {
                    return NO;
                }
                
            } else if ([filePathExtension isEqualToString: @"esd"]) {
                // TODO: Implement .esd file splitting
                if (!progressController(currentFile, DWMessageUnsupportedOperation)) {
                    return NO;
                }
            } else {
                if (!progressController(currentFile, DWMessageFileIsTooLarge)) {
                    return NO;
                }
            }
            continue;
        }
        
        /*
         * Writing Files to the destination path
         */
        
        if (!progressController(currentFile, DWMessageWriteFileProcess)) {
            return NO;
        }
        
        if (![localFileManager fileExistsAtPath:[currentFile destinationPath]]) {
            NSError *copyFileError;
            BOOL copyWasSuccessful = [localFileManager copyItemAtPath: [currentFile sourcePath]
                                                               toPath: [currentFile destinationPath]
                                                                error: &copyFileError
            ];
            
            if (!progressController(currentFile, (copyWasSuccessful ? DWMessageWriteFileSuccess : DWMessageWriteFileFailure))) {
                return NO;
            }
        } else {
            if (!progressController(currentFile, DWMessageEntityAlreadyExists)) {
                return NO;
            }
        }
        
    }
    
    /*
     * Checking if '$image/efi/boot' does not exist.
     * This usually means that the image is Windows 7
     * In such a situation, we need to do the following:
     * 1) Copy '$image/efi/microsoft/boot/' → '$image/efi/boot/'
     * 2) Extract '$image/sources/install.wim/1/Windows/Boot/EFI/bootmgfw.efi' → '$image/efi/boot/bootx64.efi'
     */
   
    /*
    BOOL bootIsFolder = NO;
    BOOL bootEntityExists = [localFileManager fileExistsAtPath: [sourcePath stringByAppendingPathComponent:@"/image/efi/boot"]
                                                   isDirectory: &bootIsFolder];
    
    if (bootEntityExists && bootIsFolder) {
        IOLog(@"Is Windows 7 Image");
    } else {
        IOLog(@"Not Windows 7 Image")
    }*/
    
    return YES;
}

@end
