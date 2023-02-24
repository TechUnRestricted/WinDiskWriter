//
//  DiskWriter.h
//  windiskwriter
//
//  Created by Macintosh on 26.01.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "DWAction.h"
#import "BootModes.h"
#import "DWFilesContainer.h"

enum DWMessage {
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
    DWErrorCodeSourceIsTooLarge,
    DWErrorCodeGetDiskAvailableSpaceFailure
};

struct FileWriteInfo {
    NSString * _Nonnull sourceFilePath;
    NSString * _Nonnull destinationFilePath;
    UInt64 entitiesRemain;
};

typedef enum DWAction (^DWCallback)(DWFile * _Nonnull fileInfo, enum DWMessage message);

@interface DiskWriter: NSObject

@property (strong, nonatomic, readonly) DWFilesContainer *_Nonnull filesContainer;
@property (strong, nonatomic, readonly) NSString *_Nonnull destinationPath;
@property (strong, nonatomic, readonly) BootMode _Nonnull bootMode;
@property (strong, nonatomic, readonly) Filesystem _Nonnull destinationFilesystem;

- (instancetype _Nonnull )init NS_UNAVAILABLE;
- (instancetype _Nonnull)initWithDWFilesContainer: (DWFilesContainer * _Nonnull)filesContainer
                                  destinationPath: (NSString * _Nonnull)destinationPath
                                         bootMode: (BootMode _Nonnull)bootMode
                            destinationFilesystem: (Filesystem _Nonnull)destinationFilesystem;

- (BOOL)writeWindows_8_10_ISOWithError: (NSError *_Nonnull *_Nonnull)error
                              callback: (DWCallback _Nonnull)callback;

@end
