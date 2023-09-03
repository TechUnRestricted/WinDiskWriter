//
//  DiskWriter.h
//  windiskwriter
//
//  Created by Macintosh on 26.01.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "DWProgress.h"

#import "BootModes.h"
#import "DWFilesContainer.h"

typedef NS_ENUM(NSUInteger, DWOperationResult) {
    DWOperationResultStart,
    DWOperationResultProcess,
    DWOperationResultSuccess,
    DWOperationResultFailure,
    // DWOperationResultNotApplicable,
    DWOperationResultSkipped
};

typedef NS_ENUM(NSUInteger, DWOperationType) {
    DWOperationTypeCreateDirectory,
    DWOperationTypeWriteFile,
    DWOperationTypeSplitWindowsImage,
    
    /* Required only for Windows Vista / 7 */
    DWOperationTypeExtractWindowsBootloader,
    
    /* Optional for Windows 11 and up.
     Removes TPM and Secure Boot requirements by setting
     the types of all images inside install(.wim)/(.esd) to "Server" */
    DWOperationTypePatchWindowsInstallerRequirements
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

@interface DiskWriter: NSObject

NS_ASSUME_NONNULL_BEGIN

@property (strong, nonatomic, readonly) DWFilesContainer *_Nonnull filesContainer;
@property (strong, nonatomic, readonly) NSString *_Nonnull destinationPath;
@property (strong, nonatomic, readonly) BootMode _Nonnull bootMode;
@property (strong, nonatomic, readonly) Filesystem _Nonnull destinationFilesystem;
@property (nonatomic, readonly) BOOL patchInstallerRequirements;

- (instancetype _Nonnull )init NS_UNAVAILABLE;

- (instancetype _Nonnull)initWithDWFilesContainer: (DWFilesContainer * _Nonnull)filesContainer
                                  destinationPath: (NSString * _Nonnull)destinationPath
                                         bootMode: (BootMode _Nonnull)bootMode
                            destinationFilesystem: (Filesystem _Nonnull)destinationFilesystem
                               skipSecurityChecks: (BOOL)skipSecurityChecks;

typedef DWAction (^ChainedCallbackAction)(DWFile *dwFile, uint64 copiedBytes, DWOperationType operationType, DWOperationResult operationResult, NSError *error);

- (BOOL)startWritingWithError: (NSError **)error
             progressCallback: (ChainedCallbackAction)progressCallback;

NS_ASSUME_NONNULL_END

@end
