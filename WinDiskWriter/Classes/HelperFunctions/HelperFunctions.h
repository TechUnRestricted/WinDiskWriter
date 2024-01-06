//
//  HelperFunctions.h
//  windiskwriter
//
//  Created by Macintosh on 27.01.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DiskManager.h"

NS_ASSUME_NONNULL_BEGIN

#define IOLog(FORMAT, ...) fprintf(stderr,"%s\n", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);

@interface HelperFunctions : NSObject

- (instancetype)init NS_UNAVAILABLE;

+ (BOOL)requiresLegacyBootloaderFilesDownload;

+ (NSArray<NSString *> *)notDownloadedGrub4DosFilesArray;

+ (NSString *)applicationFilesFolder;

+ (NSString *)applicationTempFolder;

+ (NSString *)applicationGrub4DosFolder;

+ (NSString *)grub4DosDownloadLinkBase;

+ (NSArray<NSString *> *)grub4dosFileNames;

+ (void)cleanupTempFolders;

+ (void)quitApplication;

+ (BOOL)hasElevatedRights;

+ (void)openDonationsPage;

+ (void)printTimeElapsedWhenRunningCode: (NSString *)title
                              operation: (void (^)(void))operation;

+ (BOOL)restartWithElevatedPermissionsWithError: (NSError *_Nonnull *_Nonnull)error;

+ (NSString *)randomStringWithLength: (UInt64)requiredLength;

+ (NSString *_Nullable)windowsSourceMountPath: (NSString *_Nonnull)sourcePath
                                        error: (NSError *_Nullable *_Nullable)error;

+ (DiskManager *_Nullable)diskManagerWithDevicePath: (NSString *)devicePath
                                        isBSDDevice: (BOOL *_Nullable)isBSDDevice
                                              error: (NSError *_Nullable *_Nullable)error;

+ (NSString *)unitFormattedSizeFor: (UInt64)bytes;

@end

NS_ASSUME_NONNULL_END
