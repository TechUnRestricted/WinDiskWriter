//
//  DAWrapper.h
//  windiskwriter
//
//  Created by Macintosh on 27.01.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

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
- (struct DiskInfo) getDiskInfo;
@end

NS_ASSUME_NONNULL_END
