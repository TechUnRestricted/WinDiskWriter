//
//  DAWrapper.h
//  windiskwriter
//
//  Created by Macintosh on 27.01.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DiskArbitration/DiskArbitration.h>

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

struct DiskInfo {
    BOOL isDrive;
    BOOL isInternal;
    BOOL isMountable;
    BOOL isRemovable;
    BOOL isDeviceUnit;
    BOOL isWritable;
    BOOL isBSDUnit;
    BOOL isEncrypted;
    BOOL isNetworkVolume;
    BOOL isEjectable;
    
    NSNumber *mediaSize;
    NSNumber *blockSize;
    NSNumber *appearanceTime;
    
    NSString *devicePath;
    NSString *deviceModel;
    NSString *BSDName;
    NSString *mediaKind;
    NSString *mediaPath;
    NSString *mediaName;
    NSString *mediaContent;
    NSString *busPath;
    NSString *deviceProtocol;
    NSString *deviceRevision;
    NSString *busName;
    NSString *deviceVendor;
    NSString *uuid;
};

@interface DAWrapper : NSObject
- (instancetype)init NS_UNAVAILABLE;
- (instancetype _Nullable)initWithBSDName: (NSString * _Nonnull)bsdName API_AVAILABLE(macosx(10.4));
- (instancetype _Nullable)initWithVolumePath: (NSString * _Nonnull)volumePath API_AVAILABLE(macosx(10.7));

- (DAReturn)unmountDiskWithOptions: (DADiskUnmountOptions)options;
- (DAReturn)mountDiskWithOptions: (DADiskMountOptions)options;

- (struct DiskInfo) getDiskInfo;
@end

NS_ASSUME_NONNULL_END
