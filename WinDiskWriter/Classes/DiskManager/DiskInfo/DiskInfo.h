//
//  DiskInfo.h
//  windiskwriter
//
//  Created by Macintosh on 07.09.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DiskInfo : NSObject

@property (readwrite, nonatomic) BOOL isWholeDrive;
@property (readwrite, nonatomic) BOOL isInternal;
@property (readwrite, nonatomic) BOOL isMountable;
@property (readwrite, nonatomic) BOOL isRemovable;
@property (readwrite, nonatomic) BOOL isDeviceUnit;
@property (readwrite, nonatomic) BOOL isWritable;
@property (readwrite, nonatomic) BOOL isEncrypted;
@property (readwrite, nonatomic) BOOL isNetworkVolume;
@property (readwrite, nonatomic) BOOL isEjectable;

@property (readwrite, retain, nonatomic, nullable) NSNumber *BSDUnit;

@property (readwrite, retain, nonatomic, nullable) NSNumber *mediaSize;
@property (readwrite, retain, nonatomic, nullable) NSNumber *mediaBSDMajor;
@property (readwrite, retain, nonatomic, nullable) NSNumber *mediaBSDMinor;

@property (readwrite, retain, nonatomic, nullable) NSNumber *blockSize;
@property (readwrite, retain, nonatomic, nullable) NSNumber *appearanceTime;

@property (readwrite, retain, nonatomic, nullable) NSString *devicePath;
@property (readwrite, retain, nonatomic, nullable) NSString *deviceModel;
@property (readwrite, retain, nonatomic, nullable) NSString *BSDName;
@property (readwrite, retain, nonatomic, nullable) NSString *mediaKind;
@property (readwrite, retain, nonatomic, nullable) NSString *volumeKind;
@property (readwrite, retain, nonatomic, nullable) NSString *volumeName;
@property (readwrite, retain, nonatomic, nullable) NSString *volumePath;
@property (readwrite, retain, nonatomic, nullable) NSString *mediaPath;
@property (readwrite, retain, nonatomic, nullable) NSString *mediaName;
@property (readwrite, retain, nonatomic, nullable) NSString *mediaContent;
@property (readwrite, retain, nonatomic, nullable) NSString *busPath;
@property (readwrite, retain, nonatomic, nullable) NSString *deviceProtocol;
@property (readwrite, retain, nonatomic, nullable) NSString *deviceRevision;
@property (readwrite, retain, nonatomic, nullable) NSString *busName;
@property (readwrite, retain, nonatomic, nullable) NSString *deviceVendor;
@property (readwrite, retain, nonatomic, nullable) NSString *volumeUUID;

- (NSDate *_Nullable)appearanceNSDate;
- (NSString *_Nullable)BSDFullPath;

@end

NS_ASSUME_NONNULL_END
