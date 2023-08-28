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
    localFileManager = [NSFileManager defaultManager];
    
    _filesContainer = filesContainer;
    _destinationPath = destinationPath;
    _bootMode = bootMode;
    _destinationFilesystem = destinationFilesystem;
    _skipSecurityChecks = skipSecurityChecks;
    
    return self;
}

#define CallbackHandler(originalFileSizeBytes, writtenBytes, dwMessage)     \
switch (callback(originalFileSizeBytes, writtenBytes, dwMessage)) {         \
case DWActionContinue:                                                      \
break;                                                                      \
case DWActionSkip:                                                          \
case DWActionStop:                                                          \
return NO;                                                                  \
}

typedef DWAction (^ChainedCallbackAction)(uint64 originalFileSizeBytes, uint64 copiedBytes, DWMessage dwMessage);

- (BOOL)copyFileWithDWFile: (DWFile *)dwFile
       destinationFilePath: (NSString *)destinationFilePath
                bufferSize: (NSUInteger)bufferSize
                  callback: (ChainedCallbackAction)callback {
    
    NSString *sourcePath = [self.filesContainer.containerPath stringByAppendingPathComponent: dwFile.sourcePath];
    
    // Check if we can write a file to the destination filesystem
    if (self.destinationFilesystem == FilesystemFAT32 && dwFile.size > FAT32_MAX_FILE_SIZE) {
        // *error = [NSError errorWithStringValue: @"Can't copy this file to the FAT32 volume due to filesystem limitations"];
        
        CallbackHandler(dwFile.size, 0, DWMessageWriteFileFailure);
        
        return NO;
    }
    
    // Open the source file in read mode
    FILE *source = fopen([sourcePath UTF8String], "rb");
    if (source == NULL) {
        // *error = [NSError errorWithStringValue: @"Couldn't open source file."];
        
        CallbackHandler(dwFile.size, 0, DWMessageWriteFileFailure);
        
        return NO;
    }
    
    // Open the destination file in write mode
    FILE *destination = fopen([destinationFilePath UTF8String], "wb");
    if (destination == NULL) {
        // *error = [NSError errorWithStringValue: @"Couldn't open destination file path."];
        
        fclose(source);
        
        CallbackHandler(dwFile.size, 0, DWMessageWriteFileFailure);
        
        return NO;
    }
    
    // Allocate a buffer
    char *buffer = malloc(bufferSize);
    if (buffer == NULL) {
        // *error = [NSError errorWithStringValue: @"Couldn't allocate memory for buffer."];
        
        fclose(source);
        fclose(destination);
        
        CallbackHandler(dwFile.size, 0, DWMessageWriteFileFailure);
        
        return NO;
    }
    
    fseek(source, 0, SEEK_END);
    uint64_t sourceSize = ftell(source);
    fseek(source, 0, SEEK_SET);
    
    // Initialize the progress variables
    uint64_t bytesRead = 0;
    uint64_t bytesWritten = 0;
    
    CallbackHandler(sourceSize, bytesWritten, DWMessageWriteFileProcess);
    
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
            // *error = [NSError errorWithStringValue: @"Can't write data to destination path."];
            
            free(buffer);
            fclose(source);
            fclose(destination);
            
            CallbackHandler(sourceSize, bytesWritten, DWMessageWriteFileFailure);
            
            return NO;
        }
        
        // Update the progress variables
        bytesRead += read_size;
        bytesWritten += write_size;
        
        CallbackHandler(sourceSize, bytesWritten, DWMessageWriteFileProcess);
    }
    
    // Free the buffer and close the files
    free(buffer);
    fclose(source);
    fclose(destination);
    
    CallbackHandler(sourceSize, bytesWritten, DWMessageWriteFileSuccess);
    
    return YES;
}

- (void)writeWindowsInstallWithDWFile: (DWFile *)dwFile
                      destinationPath: (NSString *)destinationPath
                             callback: (ChainedCallbackAction)callback {
    
    NSString *sourcePath = [self.filesContainer.containerPath stringByAppendingPathComponent:dwFile.sourcePath];
    
    /*
     [Windows Image Install File is less than FAT32 max file size limit]
     or
     [Selected Filesystem is not FAT32]
     */
    
    
    BOOL requiresSplitting = !((dwFile.size <= FAT32_MAX_FILE_SIZE && self.destinationFilesystem == FilesystemFAT32) || self.destinationFilesystem == FilesystemExFAT);
    
    NSString *_tempSecurityBypassImageLocation;
    
    // Check if we can write Windows Image file without modifications
    if (!requiresSplitting) {
        
        // Copying Windows Image
        __block DWAction latestAction = DWActionContinue;
        
        BOOL copyWasSuccessfull = [self copyFileWithDWFile: dwFile
                                       destinationFilePath: destinationPath
                                                bufferSize: COPY_BUFFER_SIZE
                                                  callback: ^DWAction (uint64 originalFileSizeBytes, uint64 copiedBytes, DWMessage dwMessage) {
            
            latestAction = callback(originalFileSizeBytes, copiedBytes, dwMessage);
            
            return latestAction;
        }];
        
        // We don't need to continue unless copying wasn't successful. All further operations require a success from the previous operation.
        if (!copyWasSuccessfull) {
            return;
        }
        
        if (latestAction == DWActionStop) {
            return;
        }
        
        _tempSecurityBypassImageLocation = destinationPath;
        
    } else {
        // Splitting Windows Install Images with .esd and .swm extensions is currently not supported
        if (![sourcePath.lowercaseString.pathExtension isEqualToString:@"wim"]) {
            
            CallbackHandler(dwFile.size, 0, DWMessageUnsupportedOperation);
            
            return NO;
        }
        
        if (self.skipSecurityChecks) {
            NSString *randomFolderName = [NSString stringWithFormat:@"windiskwriter-%@", [HelperFunctions randomStringWithLength:10]];
            NSString *tempDirectory = [NSString pathWithComponents:@[NSTemporaryDirectory(), randomFolderName]];

            CallbackHandler(dwFile.size, 0, DWMessageCreateDirectoryProcess);

            BOOL directoryCreatedSuccessfully = [localFileManager createDirectoryAtPath: tempDirectory
                                                            withIntermediateDirectories: YES
                                                                             attributes: NULL
                                                                                  error: NULL];
            
            CallbackHandler(dwFile.size, 0, (directoryCreatedSuccessfully ? DWMessageCreateDirectorySuccess : DWMessageCreateDirectoryFailure));
            
            // We don't need to continue unless creating a directory wasn't successful. All further operations require a success from the previous operation.
            if (!directoryCreatedSuccessfully) {
                return;
            }
            
            // Setting the temporary location for install image file. (Example: /var/folders/b2/zvoxm8cn7995b9jnt2love090000gn/T/windiskwriter-ABCDEFGHI1/install.wim)
            _tempSecurityBypassImageLocation = [tempDirectory stringByAppendingPathComponent: sourcePath.lastPathComponent];
            
            [self copyFileWithDWFile: dwFile
                 destinationFilePath: _tempSecurityBypassImageLocation
                          bufferSize: COPY_BUFFER_SIZE
                            callback: ^DWAction(uint64 originalFileSizeBytes, uint64 copiedBytes, DWMessage dwMessage) {
               
                return NO;
            }];
            
            
        }
    }
    
    // Removing security checks on Windows Image (TPM + SecureBoot bypass)
    if (self.skipSecurityChecks) {
        CallbackHandler(dwFile.size, 0, DWMessageBypassWindowsSecurityChecksProcess);
        
        WimlibWrapper *wimlibWrapper = [[WimlibWrapper alloc] initWithWimPath: _tempSecurityBypassImageLocation];
        BOOL *securityChecksSuccessfullyBypassed = [wimlibWrapper bypassWindowsSecurityChecks];
        
        CallbackHandler(dwFile.size, 0, securityChecksSuccessfullyBypassed ? DWMessageBypassWindowsSecurityChecksSuccess : DWMessageBypassWindowsSecurityChecksFailure);
    }
    
    
    /*
     Splitting install.wim file in order to fit into FAT32 partition
     */
    {
        UInt8 partsCount = ceil((double)dwFile.size / (double)FAT32_MAX_FILE_SIZE);
        UInt32 maxSliceSize = dwFile.size / partsCount;
        
        CallbackHandler(dwFile.size, 0, DWMessageSplitWindowsImageProcess);
        
        WimlibWrapper *wimlibWrapper = [[WimlibWrapper alloc] initWithWimPath:sourcePath];
        enum wimlib_error_code wimlibReturnCode = [wimlibWrapper splitWithDestinationDirectoryPath: [destinationPath stringByDeletingLastPathComponent]
                                                                               maxSliceSizeInBytes: maxSliceSize
                                                                                   progressHandler: NULL
                                                                                           context: NULL];
        
        CallbackHandler(dwFile.size, 0, (wimlibReturnCode == WIMLIB_ERR_SUCCESS) ? DWMessageSplitWindowsImageSuccess : DWMessageSplitWindowsImageFailure);
    }
    
    return YES;
}

- (BOOL)startWritingWithError: (NSError **)error
             progressCallback: (NewDWCallback)progressCallback {
    
#define DWCallbackHandler(currentFile, bytesWritten, message)    \
switch (progressCallback(currentFile, bytesWritten, message)) {  \
case DWActionContinue:                                       \
break;                                                   \
case DWActionStop:                                           \
return NO;                                               \
case DWActionSkip:                                           \
continue;                                                \
}
    
    if (![self commonErrorCheckerWithError:error]) {
        return NO;
    }
    
    DWFile *installerWIMPackagePath = NULL;
    BOOL hasEFIBootloader = NO;
    
    for (DWFile *currentFile in [self.filesContainer files]) {
        NSString *absoluteSourcePath = [self.filesContainer.containerPath stringByAppendingPathComponent:currentFile.sourcePath];
        NSString *absoluteDestinationPath = [_destinationPath stringByAppendingPathComponent:currentFile.sourcePath];
        
        NSString *lastPathComponent = [[[currentFile sourcePath] lastPathComponent] lowercaseString];
        
        // [Detected file type: Directory]
        if (currentFile.fileType == NSFileTypeDirectory) {
            DWCallbackHandler(currentFile, 0, DWMessageCreateDirectoryProcess);
            
            NSError *createDirectoryError = NULL;
            BOOL directoryCreateSuccess = [localFileManager createDirectoryAtPath: absoluteDestinationPath
                                                      withIntermediateDirectories: YES
                                                                       attributes: NULL
                                                                            error: &createDirectoryError];
            
            DWCallbackHandler(currentFile, 0, (directoryCreateSuccess ? DWMessageCreateDirectorySuccess : DWMessageCreateDirectoryFailure));
            
            continue;
        }
        
        // [Detected file type: Windows Install Image]
        if ([lastPathComponent hasOneOfTheSuffixes:@[@"install.wim", @"install.esd"]]) {
            __block DWAction lastAction = DWActionContinue;
            
            [self writeWindowsInstallWithDWFile: currentFile
                                destinationPath: absoluteDestinationPath
                                       callback: ^DWAction(uint64 originalFileSizeBytes, uint64 copiedBytes, DWMessage dwMessage) {
                
                lastAction = progressCallback(currentFile, copiedBytes, dwMessage);
                
                return lastAction;
            }];
            
            if (lastAction == DWActionStop) {
                return NO;
            }
            
            continue;
        }
        
        // [Detected file type: Regular File]
        {
            __block DWAction lastAction = DWActionContinue;
            
            BOOL copyingWasSuccessfull = [self copyFileWithDWFile: currentFile
                                              destinationFilePath: absoluteDestinationPath
                                                       bufferSize: COPY_BUFFER_SIZE
                                                         callback: ^DWAction(uint64 originalFileSizeBytes, uint64 copiedBytes, DWMessage dwMessage) {
                
                lastAction = progressCallback(currentFile, copiedBytes, dwMessage);
                
                return lastAction;
            }];
            
            if (lastAction == DWActionStop) {
                return NO;
            }
            
            continue;
        }
    }
    
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


- (BOOL)commonWriteWithError: (NSError *_Nonnull *_Nonnull)error
                    callback: (DWCallback _Nonnull)callback {
    
    return YES;
}

- (BOOL)extractBootloaderFromInstallFile: (NSString *_Nonnull)installFile {
    WimlibWrapper *wimlibWrapper = [[WimlibWrapper alloc] initWithWimPath: installFile];
    
    NSString *bootloaderDestinationDirectory = [self.destinationPath stringByAppendingPathComponent: @"efi/boot/"];
    
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
