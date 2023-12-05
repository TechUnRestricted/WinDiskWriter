//
//  DiskWriter.h
//  windiskwriter
//
//  Created by Macintosh on 26.01.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "DWProgress.h"

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
    DWOperationTypePatchWindowsInstallerRequirements,
    DWOperationTypeInstallLegacyBootSector
};

@interface DiskWriter: NSObject

NS_ASSUME_NONNULL_BEGIN

@property (strong, nonatomic, readonly) DWFilesContainer *filesContainer;
@property (strong, nonatomic, readonly) NSString *destinationPath;
@property (strong, nonatomic, readonly) DiskManager *destinationDiskManager;

@property (strong, nonatomic, readwrite) Filesystem destinationFilesystem;
@property (nonatomic, readwrite) BOOL patchInstallerRequirements;
@property (nonatomic, readwrite) BOOL installLegacyBoot;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithDWFilesContainer: (DWFilesContainer *)filesContainer
                         destinationPath: (NSString *)destinationPath
                  destinationDiskManager: (DiskManager *)destinationDiskManager;

typedef DWAction (^ChainedCallbackAction)(DWFile *dwFile, uint64 copiedBytes, DWOperationType operationType, DWOperationResult operationResult, NSError *_Nullable error);

- (BOOL)startWritingWithError: (NSError **)error
             progressCallback: (ChainedCallbackAction)progressCallback;

+ (NSString *)bootloaderMBRFilePath;
+ (NSString *)bootloaderGrldrFilePath;

NS_ASSUME_NONNULL_END

@end
