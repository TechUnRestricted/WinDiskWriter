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
#import "NSError+Common.h"
#import "WimlibWrapper.h"
#include <sys/statvfs.h>
#import "DiskManager.h"
#import "Filesystems.h"
#import "DiskWriter.h"
#import "BootModes.h"
#import "constants.h"
#import "HDIUtil.h"

const uint32_t FAT32_MAX_FILE_SIZE = UINT32_MAX;

// 8MB Buffer for copying files with interrupt-like callback
const uint64_t COPY_BUFFER_SIZE = 8388608;

@implementation DiskWriter {
    NSFileManager *localFileManager;
}

- (instancetype _Nonnull)initWithDWFilesContainer: (DWFilesContainer * _Nonnull)filesContainer
                                  destinationPath: (NSString * _Nonnull)destinationPath
                                         bootMode: (BootMode _Nonnull)bootMode
                            destinationFilesystem: (Filesystem _Nonnull)destinationFilesystem
                               skipSecurityChecks: (BOOL)skipSecurityChecks {
    
    // Just in case ¯\_(ツ)_/¯
    localFileManager = [NSFileManager defaultManager];
    
    _filesContainer = filesContainer;
    _destinationPath = destinationPath;
    _bootMode = bootMode;
    _destinationFilesystem = destinationFilesystem;
    _patchInstallerRequirements = skipSecurityChecks;
    
    return self;
}

- (UInt64)freeSpaceInPath: (NSString *)path
                    error: (NSError **)error {
    struct statvfs stat;
    
    if (statvfs([path UTF8String], &stat) != 0) {
        *error = [NSError errorWithStringValue: @"Can't get the available space for the specified path."];
        return 0;
    }

    // the available size is f_frsize * f_bavail
    return stat.f_frsize * stat.f_bavail;
}

- (BOOL)copyFileWithDWFile: (DWFile *)dwFile
       destinationFilePath: (NSString *)destinationFilePath
                bufferSize: (NSUInteger)bufferSize
     ignoreFilesystemCheck: (BOOL)ignoreFilesystemCheck
                  callback: (ChainedCallbackAction)callback {
    
    /*
     Macro for handling callback
     */
#define CallbackHandler(dwFile, writtenBytes, operationType, operationResult, error)                    \
switch (callback(dwFile, writtenBytes, operationType, operationResult, error)) {                        \
case DWActionContinue:                                                                                  \
break;                                                                                                  \
case DWActionSkip:                                                                                      \
case DWActionStop:                                                                                      \
return NO;                                                                                              \
}

#define CallbackHandlerWithCleanupOnStop(dwFile, writtenBytes, operationType, operationResult, error)     \
switch (callback(dwFile, writtenBytes, operationType, operationResult, error)) {                          \
case DWActionContinue:                                                                                    \
break;                                                                                                    \
case DWActionSkip:                                                                                        \
case DWActionStop: {                                                                                      \
free(buffer);                                                                                             \
fclose(source);                                                                                           \
fclose(destination);                                                                                      \
return NO;                                                                                                \
}                                                                                                         \
}

//
    NSString *sourcePath = [self.filesContainer.containerPath stringByAppendingPathComponent: dwFile.sourcePath];
    
    NSError *freeSpaceInPathError = NULL;
    UInt64 availableSpace = [self freeSpaceInPath: [destinationFilePath stringByDeletingLastPathComponent]
                                            error: &freeSpaceInPathError];
    
    if (freeSpaceInPathError != NULL) {
        CallbackHandler(dwFile, 0, DWOperationTypeWriteFile, DWOperationResultFailure, freeSpaceInPathError);
        
        return NO;
    }
    
    if (dwFile.size > availableSpace) {
        NSError *error = [NSError errorWithStringValue: @"Not enough free disk space."];
        
        CallbackHandler(dwFile, 0, DWOperationTypeWriteFile, DWOperationResultFailure, error);
        
        return NO;
    }
    
    // Check if we can write a file to the destination filesystem
    if ((self.destinationFilesystem == FilesystemFAT32 && dwFile.size > FAT32_MAX_FILE_SIZE) && !ignoreFilesystemCheck) {
        NSError *error = [NSError errorWithStringValue: @"Can't copy this file to the FAT32 volume due to filesystem limitations."];
        
        CallbackHandler(dwFile, 0, DWOperationTypeWriteFile, DWOperationResultFailure, error);
        
        return NO;
    }
    
    // Open the source file in read mode
    FILE *source = fopen([sourcePath UTF8String], "rb");
    if (source == NULL) {
        NSError *error = [NSError errorWithStringValue: @"Couldn't open source file."];
        
        CallbackHandler(dwFile, 0, DWOperationTypeWriteFile, DWOperationResultFailure, error);
        
        return NO;
    }
    
    // Open the destination file in write mode
    FILE *destination = fopen([destinationFilePath UTF8String], "wb");
    if (destination == NULL) {
        NSError *error = [NSError errorWithStringValue: @"Couldn't open destination file path."];
        
        fclose(source);
        
        CallbackHandler(dwFile, 0, DWOperationTypeWriteFile, DWOperationResultFailure, error);
        
        return NO;
    }
    
    // Allocate a buffer
    char *buffer = malloc(bufferSize);
    if (buffer == NULL) {
        NSError *error = [NSError errorWithStringValue: @"Couldn't allocate memory for buffer."];
        
        fclose(source);
        fclose(destination);
        
        CallbackHandler(dwFile, 0, DWOperationTypeWriteFile, DWOperationResultFailure, error);
        
        return NO;
    }
    
    // Checking the size once again because it can be changed by user or system ¯\_(ツ)_/¯
    fseek(source, 0, SEEK_END);
    uint64_t sourceSize = ftell(source);
    //[dwFile setSize: sourceSize];
    
    fseek(source, 0, SEEK_SET);
    
    // Initialize the progress variables
    uint64_t bytesRead = 0;
    uint64_t bytesWritten = 0;
    
    
    CallbackHandlerWithCleanupOnStop(dwFile, 0, DWOperationTypeWriteFile, DWOperationResultStart, NULL);
    
    // Copy the file using the buffer
    while (true) {
        
        size_t read_size = fread(buffer, 1, bufferSize, source);
        if (read_size == 0) {
            // End of file reached
            break;
        }
        
        // Write the chunk of data to the destination file
        size_t write_size = fwrite(buffer, 1, read_size, destination);
        if (write_size != read_size) {
            NSError *error = [NSError errorWithStringValue: @"Can't write data to destination path."];
            
            free(buffer);
            fclose(source);
            fclose(destination);
            
            CallbackHandler(dwFile, bytesWritten, DWOperationTypeWriteFile, DWOperationResultFailure, error);
            
            return NO;
        }
        
        // Update the progress variables
        bytesRead += read_size;
        bytesWritten += write_size;
        
        CallbackHandlerWithCleanupOnStop(dwFile, bytesWritten, DWOperationTypeWriteFile, DWOperationResultProcess, NULL);
    }
    
    // Free the buffer and close the files
    free(buffer);
    fclose(source);
    fclose(destination);
    
    CallbackHandler(dwFile, bytesWritten, DWOperationTypeWriteFile, DWOperationResultSuccess, NULL);
    
    return YES;
}

- (BOOL)writeWindowsInstallWithDWFile: (DWFile *)dwFile
                      destinationPath: (NSString *)destinationPath
                             callback: (ChainedCallbackAction)callback {
    
    /*
     Macro for handling callback with cleanup of temporary files.
     We need it since we are make a copy of Windows Install Image on the system drive in order to patch it.
     I don't think that there can be a better solution without "goto cleanup" and macros.
     */
    
#define CallbackHandlerWithCleanup(dwFile, writtenBytes, operationType, operationResult, error)                 \
switch (callback(dwFile, writtenBytes, operationType, operationResult, error)) {                                \
case DWActionContinue:                                                                                          \
break;                                                                                                          \
case DWActionSkip:                                                                                              \
case DWActionStop:                                                                                              \
goto cleanup;                                                                                                   \
}

//
    NSString *sourcePath = [self.filesContainer.containerPath stringByAppendingPathComponent:dwFile.sourcePath];
    
    // Determining the success of the operation for "goto cleanup"
    BOOL operationWasSuccessful = NO;
    
    /*
     [Windows Image Install File is less than FAT32 max file size limit]
     or
     [Selected Filesystem is not FAT32]
     */
    
    BOOL requiresSplitting = !((dwFile.size <= FAT32_MAX_FILE_SIZE && self.destinationFilesystem == FilesystemFAT32) || self.destinationFilesystem == FilesystemExFAT);
    NSString *tempDirectory = NULL;
    
    // Check if we can write Windows Image file without modifications
    if (!requiresSplitting) {
        
        __block DWAction latestAction = DWActionContinue;
        
        // Copying Windows Image
        BOOL copyWasSuccessfull = [self copyFileWithDWFile: dwFile
                                       destinationFilePath: destinationPath
                                                bufferSize: COPY_BUFFER_SIZE
                                     ignoreFilesystemCheck: YES
                                                  callback: ^DWAction(DWFile *dwFile, uint64 copiedBytes, DWOperationType operationType, DWOperationResult operationResult, NSError *error) {
            
            latestAction = callback(dwFile, copiedBytes, operationType, operationResult, error);
            
            return latestAction;
        }];
        
        // We don't need to continue unless copying wasn't successful. All further operations require a success from the previous operation.
        if (!copyWasSuccessfull) {
            goto cleanup;
        }
        
        if (latestAction == DWActionStop) {
            goto cleanup;
        }
        
    } else {
        if (![sourcePath.lowercaseString.pathExtension isEqualToString:@"wim"]) {
            NSError *error = [NSError errorWithStringValue: @"Splitting Windows Install Images with .esd and .swm extensions is currently not supported."];
            
            CallbackHandlerWithCleanup(dwFile, 0, DWOperationTypeSplitWindowsImage, DWOperationResultFailure, error);
            
            goto cleanup;
        }
        
        if (self.patchInstallerRequirements) {
            NSString *randomFolderName = [NSString stringWithFormat:@"install-image-%@", [HelperFunctions randomStringWithLength:10]];
            
            // Defining the path to the temporary location for the Windows Install Image on the system drive.
            tempDirectory = [NSString pathWithComponents:@[NSTemporaryDirectory(), @"windiskwriter", randomFolderName]];
            
            CallbackHandlerWithCleanup(dwFile, 0, DWOperationTypeCreateDirectory, DWOperationResultStart, NULL);
            
            NSError *directoryCreateError = NULL;
            
            BOOL directoryCreatedSuccessfully = [localFileManager createDirectoryAtPath: tempDirectory
                                                            withIntermediateDirectories: YES
                                                                             attributes: NULL
                                                                                  error: &directoryCreateError];
            
            CallbackHandlerWithCleanup(dwFile, 0, DWOperationTypeCreateDirectory, (directoryCreatedSuccessfully ? DWOperationResultSuccess : DWOperationResultFailure), directoryCreateError);
            
            // We don't need to continue unless creating a directory wasn't successful. All further operations require a success from the previous operation.
            if (!directoryCreatedSuccessfully) {
                goto cleanup;
            }
            
            // Setting the location for Windows Install Image to the NSTemporaryDirectory(). (Example: /var/folders/b2/zvoxm8cn7995b9jnt2love090000gn/T/windiskwriter-ABCDEFGHI1/install.wim)
            sourcePath = [tempDirectory stringByAppendingPathComponent: sourcePath.lastPathComponent];
            
            __block DWAction latestAction = DWActionContinue;
            
            // Copying Windows Install File into a temporary directory
            BOOL copyWasSuccessfull = [self copyFileWithDWFile: dwFile
                                           destinationFilePath: sourcePath
                                                    bufferSize: COPY_BUFFER_SIZE
                                         ignoreFilesystemCheck: YES
                                                      callback:^DWAction(DWFile *dwFile, uint64 copiedBytes, DWOperationType operationType, DWOperationResult operationResult, NSError *error) {
                
                latestAction = callback(dwFile, copiedBytes, operationType, operationResult, error);
                
                return latestAction;
            }];
            
            // We don't need to continue unless copying wasn't successful. All further operations require a success from the previous operation.
            if (!copyWasSuccessfull) {
                goto cleanup;
            }
            
            if (latestAction == DWActionStop) {
                goto cleanup;
            }
        }
    }
    
    // Patching Windows Image Installer Requirements (Relevant primarily on Windows 11 and up)
    if (self.patchInstallerRequirements) {
        CallbackHandlerWithCleanup(dwFile, 0, DWOperationTypePatchWindowsInstallerRequirements, DWOperationResultStart, NULL);
        
        WimlibWrapper *wimlibWrapper = [[WimlibWrapper alloc] initWithWimPath:
                                            /* Choosing Windows Installer Image Path based on previous operations */
                                        tempDirectory != NULL ? sourcePath : destinationPath
        ];
        
        WimlibWrapperResult installerRequirementsPatchResult = [wimlibWrapper patchWindowsRequirementsChecks];
        
        DWOperationResult operationResult;
        switch (installerRequirementsPatchResult) {
            case WimlibWrapperResultSuccess:
                operationResult = DWOperationResultSuccess;
                break;
            case WimlibWrapperResultSkipped:
                operationResult = DWOperationResultSkipped;
                break;
            case WimlibWrapperResultFailure:
                operationResult = DWOperationResultFailure;
        }
        
        CallbackHandlerWithCleanup(dwFile, 0, DWOperationTypePatchWindowsInstallerRequirements, operationResult, NULL);
    }
    
    // Splitting install.wim file in order to fit into FAT32 partition
    if (requiresSplitting) {
        UInt8 partsCount = ceil((double)dwFile.size / (double)FAT32_MAX_FILE_SIZE);
        UInt32 maxSliceSize = dwFile.size / partsCount;
        
        CallbackHandlerWithCleanup(dwFile, 0, DWOperationTypeSplitWindowsImage, DWOperationResultStart, NULL);
        
        WimlibWrapper *wimlibWrapper = [[WimlibWrapper alloc] initWithWimPath: sourcePath];
        
        __block DWAction lastAction = DWActionContinue;
        
        __block BOOL isFirstCall = YES;
        WimlibWrapperResult splitImageResult = [wimlibWrapper splitWithDestinationDirectoryPath: [destinationPath stringByDeletingLastPathComponent]
                                                                            maxSliceSizeInBytes: maxSliceSize
                                                                                       callback: ^BOOL(uint32_t totalPartsCount, uint32 currentPartNumber, uint64 bytesWritten, uint64 bytesTotal) {
            
            if (isFirstCall) {
                [dwFile setSize:bytesTotal];
                
                isFirstCall = NO;
            }
            
            lastAction = callback(dwFile, bytesWritten, DWOperationTypeSplitWindowsImage, DWOperationResultProcess, NULL);
            
            return lastAction == DWActionContinue;
        }];
        
        if (lastAction != DWActionContinue) {
            goto cleanup;
        }
        
        DWOperationResult operationResult;
        switch (splitImageResult) {
            case WimlibWrapperResultSuccess:
                operationResult = DWOperationResultSuccess;
                break;
            case WimlibWrapperResultFailure:
                operationResult = DWOperationResultFailure;
                break;
            case WimlibWrapperResultSkipped:
                operationResult = DWOperationResultSkipped;
                break;
        }
        
        CallbackHandlerWithCleanup(dwFile, 0, DWOperationTypeSplitWindowsImage, operationResult, NULL);
    }
    
    operationWasSuccessful = YES;
    
cleanup:
    if (tempDirectory != NULL) {
        [localFileManager removeItemAtPath: tempDirectory
                                     error: NULL];
    }
    
    return operationWasSuccessful;
}

- (BOOL)startWritingWithError: (NSError **)error
             progressCallback: (ChainedCallbackAction)progressCallback {
    
#define DWCallbackHandlerLoop(dwFile, writtenBytes, operationType, operationResult, error)    \
switch (progressCallback(dwFile, writtenBytes, operationType, operationResult, error)) {      \
case DWActionContinue:                                                                        \
break;                                                                                        \
case DWActionStop:                                                                            \
return NO;                                                                                    \
case DWActionSkip:                                                                            \
continue;                                                                                     \
}

if (![self commonErrorCheckerWithError:error]) {
    return NO;
}
    
    DWFile *installerWIMPackageFile = NULL;
    BOOL hasEFIBootloader = NO;
    
    for (DWFile *currentFile in [self.filesContainer files]) {
        NSString *absoluteSourcePath = [self.filesContainer.containerPath stringByAppendingPathComponent:currentFile.sourcePath];
        NSString *absoluteDestinationPath = [_destinationPath stringByAppendingPathComponent:currentFile.sourcePath];
        
        NSString *lastPathComponent = [[[currentFile sourcePath] lastPathComponent] lowercaseString];
        
        // [Detected file type: Directory]
        if (currentFile.fileType == NSFileTypeDirectory) {
            DWCallbackHandlerLoop(currentFile, 0, DWOperationTypeCreateDirectory, DWOperationResultStart, NULL);
            
            NSError *createDirectoryError = NULL;
            BOOL directoryCreateSuccess = [localFileManager createDirectoryAtPath: absoluteDestinationPath
                                                      withIntermediateDirectories: YES
                                                                       attributes: NULL
                                                                            error: &createDirectoryError];
            
            DWCallbackHandlerLoop(currentFile, 0, DWOperationTypeCreateDirectory, (directoryCreateSuccess ? DWOperationResultSuccess : DWOperationResultFailure), createDirectoryError);
            
            continue;
        }
        
        // [Detected file type: Windows Install Image]
        if ([lastPathComponent hasOneOfTheSuffixes:@[@"install.wim", @"install.esd"]]) {
            // We save the location of the Windows Install Image file for possible extraction of the EFI bootloader from it (if initially absent)
            installerWIMPackageFile = currentFile;
            
            __block DWAction lastAction = DWActionContinue;
            
            [self writeWindowsInstallWithDWFile: currentFile
                                destinationPath: absoluteDestinationPath
                                       callback: ^DWAction(DWFile * _Nonnull dwFile, uint64 copiedBytes, DWOperationType operationType, DWOperationResult operationResult, NSError * _Nonnull error) {
                
                lastAction = progressCallback(dwFile, copiedBytes, operationType, operationResult, error);
                
                return lastAction;
            }];
            
            if (lastAction == DWActionStop) {
                return NO;
            }
            
            continue;
        }
        
        // [Detected file type: Regular File]
        {
            // Check if there is a Windows bootloader for UEFI systems in the operating system files. (If it is missing, then later we will try to extract it from Install[.wim/.esd])
            NSString *relativeSourcePathLowercase = currentFile.sourcePath.lowercaseString;
            if (!hasEFIBootloader && [relativeSourcePathLowercase hasPrefix:@"efi/boot/boot"] && [relativeSourcePathLowercase.lastPathComponent hasSuffix:@".efi"]) {
                hasEFIBootloader = YES;
            }
            
            __block DWAction lastAction = DWActionContinue;
            
            BOOL copyingWasSuccessfull = [self copyFileWithDWFile: currentFile
                                              destinationFilePath: absoluteDestinationPath
                                                       bufferSize: COPY_BUFFER_SIZE
                                            ignoreFilesystemCheck: NO
                                                         callback: ^DWAction(DWFile * _Nonnull dwFile, uint64 copiedBytes, DWOperationType operationType, DWOperationResult operationResult, NSError * _Nonnull error) {
                
                lastAction = progressCallback(dwFile, copiedBytes, operationType, operationResult, error);
                
                return lastAction;
            }];
            
            if (lastAction == DWActionStop) {
                return NO;
            }
            
            continue;
        }
    }
    
    // Trying to extract a bootloader for (x86_64 systems only. There is no need to check for x86 or ARM binaries.)
    if (installerWIMPackageFile && !hasEFIBootloader) {
        // Sadly, there is no way we can do it better without creating another macro
        switch (progressCallback(installerWIMPackageFile, 0, DWOperationTypeExtractWindowsBootloader, DWOperationResultStart, NULL)) {
            case DWActionContinue:
                break;
            case DWActionSkip:
                goto postBootloaderExtract;
            case DWActionStop:
                return NO;
        }
        
        NSString *installImageAbsolutePath = [self.filesContainer.containerPath stringByAppendingPathComponent: installerWIMPackageFile.sourcePath];
        
        NSString *extractedEFIBootloaderDestinationDirectory = [self.destinationPath stringByAppendingPathComponent: @"efi/boot/"];
        
        WimlibWrapper *wimlibWrapper = [[WimlibWrapper alloc] initWithWimPath:installImageAbsolutePath];
        WimlibWrapperResult wimlibWrapperExtractionResult = [wimlibWrapper extractWindowsEFIBootloaderForDestinationDirectory:extractedEFIBootloaderDestinationDirectory];
        
        DWOperationResult operationResult;
        switch (wimlibWrapperExtractionResult) {
            case WimlibWrapperResultSuccess:
                operationResult = DWOperationResultSuccess;
                break;
            case WimlibWrapperResultFailure:
                operationResult = DWOperationResultFailure;
                break;
            case WimlibWrapperResultSkipped:
                operationResult = DWOperationResultSkipped;
                break;
        }
        
        switch (progressCallback(installerWIMPackageFile, 0, DWOperationTypeExtractWindowsBootloader, operationResult, NULL)) {
            case DWActionContinue:
                break;
            case DWActionSkip:
                goto postBootloaderExtract;
            case DWActionStop:
                return NO;
        }
    }
    
postBootloaderExtract:
    
    return YES;
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

@end
