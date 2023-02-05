//
//  DiskWriter.h
//  windiskwriter
//
//  Created by Macintosh on 26.01.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "BootModes.h"

NS_ASSUME_NONNULL_BEGIN

enum FileWriteResult {
    FileWriteResultFailure,
    FileWriteResultSuccess,
    FileWriteResultCantGetFileAttributes,
    FileWriteResultFileIsTooLarge,
    FileWriteResultUnsupportedOperation,
};

struct FileWriteInfo {
    NSString * _Nonnull sourceFilePath;
    NSString * _Nonnull destinationFilePath;
    uint64_t entitiesRemain;
    enum FileWriteResult result;
};

typedef BOOL (^FileWriteResult)(struct FileWriteInfo);

@interface DiskWriter: NSObject

- (BOOL)writeWindowsISO;

- (instancetype)init NS_UNAVAILABLE;
+ (BOOL)writeWindows11ISOWithSourcePath: (NSString * _Nonnull)sourcePath
                        destinationPath: (NSString * _Nonnull)destinationPath
     bypassTPMAndSecureBootRequirements: (BOOL)bypassTPMAndSecureBootRequirements
                               bootMode: (BootMode _Nonnull)bootMode
                                isFAT32: (BOOL)isFAT32
                                  error: (NSError **)error
                               callback: (FileWriteResult _Nullable)progressTracker;

@end

NS_ASSUME_NONNULL_END
