//
//  DiskWriter.h
//  windiskwriter
//
//  Created by Macintosh on 26.01.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "DWAction.h"
#import "DWProgress.h"

#import "BootModes.h"
#import "DWFilesContainer.h"

typedef NS_ENUM(NSUInteger, DWMessage) {
    DWMessageCreateDirectoryProcess,
    DWMessageCreateDirectorySuccess,
    DWMessageCreateDirectoryFailure,
    
    DWMessageSplitWindowsImageProcess,
    DWMessageSplitWindowsImageSuccess,
    DWMessageSplitWindowsImageFailure,
    
    /* Required only for Windows Vista / 7 */
    DWMessageExtractWindowsBootloaderProcess,
    DWMessageExtractWindowsBootloaderSuccess,
    DWMessageExtractWindowsBootloaderFailure,
    
    /* Optional for Windows 11 and up.
     Removes TPM and Secure Boot requirements by setting
     the types of all images inside install(.wim)/(.esd) to "Server" */
    DWMessageBypassWindowsSecurityChecksProcess,
    DWMessageBypassWindowsSecurityChecksSuccess,
    DWMessageBypassWindowsSecurityChecksFailure,
    
    DWMessageWriteFileProcess,
    DWMessageWriteFileSuccess,
    DWMessageWriteFileFailure,
    
    DWMessageFileIsTooLarge,
    DWMessageUnsupportedOperation,
    DWMessageEntityAlreadyExists
};

typedef NS_ENUM(NSUInteger, DWErrorCode) {
    DWErrorCodeUnsupportedBootMode,
    DWErrorCodeSourcePathDoesNotExist,
    DWErrorCodeDestinationPathDoesNotExist,
    DWErrorCodeEnumerateSourceFilesFailure,
    DWErrorCodeDiskAttributesObtainingFailure,
    DWErrorCodeSourceIsTooLarge,
    DWErrorCodeGetDiskAvailableSpaceFailure
};

struct FileWriteInfo {
    NSString *_Nonnull sourceFilePath;
    NSString *_Nonnull destinationFilePath;
    UInt64 entitiesRemain;
};

typedef enum DWAction (^DWCallback)(DWFile * _Nonnull fileInfo, enum DWMessage message);

@interface DiskWriter: NSObject

NS_ASSUME_NONNULL_BEGIN

@property (strong, nonatomic, readonly) DWFilesContainer *_Nonnull filesContainer;
@property (strong, nonatomic, readonly) NSString *_Nonnull destinationPath;
@property (strong, nonatomic, readonly) BootMode _Nonnull bootMode;
@property (strong, nonatomic, readonly) Filesystem _Nonnull destinationFilesystem;
@property (nonatomic, readonly) BOOL skipSecurityChecks;

- (instancetype _Nonnull )init NS_UNAVAILABLE;

- (instancetype _Nonnull)initWithDWFilesContainer: (DWFilesContainer * _Nonnull)filesContainer
                                  destinationPath: (NSString * _Nonnull)destinationPath
                                         bootMode: (BootMode _Nonnull)bootMode
                            destinationFilesystem: (Filesystem _Nonnull)destinationFilesystem
                               skipSecurityChecks: (BOOL)skipSecurityChecks;

- (BOOL)writeWindows_8_10_ISOWithError: (NSError *_Nonnull *_Nonnull)error
                              callback: (DWCallback _Nonnull)callback;


typedef DWAction (^NewDWCallback)(DWFile *file, uint64_t copiedBytes, DWMessage message);

- (BOOL)startWritingWithError: (NSError **)error
             progressCallback: (NewDWCallback)progressCallback;

NS_ASSUME_NONNULL_END

@end
