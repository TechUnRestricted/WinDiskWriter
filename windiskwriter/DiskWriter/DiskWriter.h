//
//  DiskWriter.h
//  windiskwriter
//
//  Created by Macintosh on 26.01.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "BootModes.h"
#import "DWFileInfo.h"

NS_ASSUME_NONNULL_BEGIN

enum DWMessage {
    DWMessageGetFileAttributesProcess,
    DWMessageGetFileAttributesSuccess,
    DWMessageGetFileAttributesFailure,
    
    DWMessageCreateDirectoryProcess,
    DWMessageCreateDirectorySuccess,
    DWMessageCreateDirectoryFailure,
    
    DWMessageSplitWindowsImageProcess,
    DWMessageSplitWindowsImageSuccess,
    DWMessageSplitWindowsImageFailure,
    
    DWMessageWriteFileProcess,
    DWMessageWriteFileSuccess,
    DWMessageWriteFileFailure,
    
    DWMessageFileIsTooLarge,
    DWMessageUnsupportedOperation,
    DWMessageEntityAlreadyExists
};

enum DWErrorCode {
    DWErrorCodeUnsupportedBootMode = 100,
    DWErrorCodeSourcePathDoesNotExist,
    DWErrorCodeDestinationPathDoesNotExist,
    DWErrorCodeEnumerateSourceFilesFailure,
    DWErrorCodeDiskAttributesObtainingFailure,
    DWErrorCodeSourceIsTooLarge
};

struct FileWriteInfo {
    NSString * _Nonnull sourceFilePath;
    NSString * _Nonnull destinationFilePath;
    uint64_t entitiesRemain;
};

typedef BOOL (^FileWriteResult)(DWFileInfo *fileInfo, enum DWMessage message);

@interface DiskWriter: NSObject

- (BOOL)writeWindowsISO;

- (instancetype)init NS_UNAVAILABLE;
+ (BOOL)writeWindows11ISOWithSourcePath: (NSString * _Nonnull)sourcePath
                        destinationPath: (NSString * _Nonnull)destinationPath
     bypassTPMAndSecureBootRequirements: (BOOL)bypassTPMAndSecureBootRequirements
                               bootMode: (BootMode _Nonnull)bootMode
                                isFAT32: (BOOL)isFAT32
                                  error: (NSError **)error
                     progressController: (FileWriteResult _Nullable)progressTracker;

@end

NS_ASSUME_NONNULL_END
