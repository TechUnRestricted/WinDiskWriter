//
//  DAWrapper.h
//  windiskwriter
//
//  Created by Macintosh on 27.01.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import <DiskArbitration/DiskArbitration.h>
#import <Foundation/Foundation.h>
#import "Filesystems/Filesystems.h"
#import "PartitionSchemes/PartitionSchemes.h"
#import "DiskInfo.h"

NS_ASSUME_NONNULL_BEGIN

/*
 enum MountUnmountResult {
 success = 0x0,                 // kDAReturnSuccess
 error = 0xF8DA0001,            // kDAReturnError
 busy = 0xF8DA0002,             // kDAReturnBusy
 badArgument = 0xF8DA0003,      // kDAReturnBadArgument
 exclusiveAccess = 0xF8DA0004,  // kDAReturnExclusiveAccess
 noResources = 0xF8DA0005,      // kDAReturnNoResources
 notFound = 0xF8DA0006,         // kDAReturnNotFound
 notMounted = 0xF8DA0007,       // kDAReturnNotMounted
 notPermitted = 0xF8DA0008,     // kDAReturnNotPermitted
 notPrivileged = 0xF8DA0009,    // kDAReturnNotPrivileged
 notReady = 0xF8DA000A,         // kDAReturnNotReady
 notWritable = 0xF8DA000B,      // kDAReturnNotWritable
 unsupported = 0xF8DA000C,      // kDAReturnUnsupported
 };
 */

@interface DiskManager : NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype _Nullable)initWithBSDName: (NSString *)bsdName API_AVAILABLE(macosx(10.4));

- (instancetype _Nullable)initWithVolumePath: (NSString *)volumePath API_AVAILABLE(macosx(10.7));

- (BOOL)unmountDiskWithOptions: (DADiskUnmountOptions)options
                         error: (NSError *_Nullable *_Nullable)error;

- (BOOL)mountDiskWithOptions: (DADiskMountOptions)options
                       error: (NSError *_Nullable *_Nullable)error;

- (BOOL)diskUtilEraseVolumeWithFilesystem: (Filesystem)filesystem
                                  newName: (NSString * _Nullable)newName
                                    error: (NSError *_Nullable *_Nullable)error;

- (BOOL)diskUtilEraseDiskWithPartitionScheme: (PartitionScheme _Nonnull)partitionScheme
                                  filesystem: (Filesystem _Nonnull)filesystem
                                     newName: (NSString * _Nullable)newName
                                       error: (NSError *_Nullable *_Nullable)error;

+ (BOOL)isBSDPath: (NSString *)path;

- (DiskInfo *)diskInfo;

+ (NSArray *)BSDDrivesNames;

@end

NS_ASSUME_NONNULL_END
