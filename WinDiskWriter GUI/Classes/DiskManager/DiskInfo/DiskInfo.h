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

@property (readwrite, retain, nonatomic) NSNumber *BSDUnit;

@property (readwrite, retain, nonatomic) NSNumber *mediaSize;
@property (readwrite, retain, nonatomic) NSNumber *mediaBSDMajor;
@property (readwrite, retain, nonatomic) NSNumber *mediaBSDMinor;

@property (readwrite, retain, nonatomic) NSNumber *blockSize;
@property (readwrite, retain, nonatomic) NSNumber *appearanceTime;

@property (readwrite, retain, nonatomic) NSString *devicePath;
@property (readwrite, retain, nonatomic) NSString *deviceModel;
@property (readwrite, retain, nonatomic) NSString *BSDName;
@property (readwrite, retain, nonatomic) NSString *mediaKind;
@property (readwrite, retain, nonatomic) NSString *volumeKind;
@property (readwrite, retain, nonatomic) NSString *volumeName;
@property (readwrite, retain, nonatomic) NSString *volumePath;
@property (readwrite, retain, nonatomic) NSString *mediaPath;
@property (readwrite, retain, nonatomic) NSString *mediaName;
@property (readwrite, retain, nonatomic) NSString *mediaContent;
@property (readwrite, retain, nonatomic) NSString *busPath;
@property (readwrite, retain, nonatomic) NSString *deviceProtocol;
@property (readwrite, retain, nonatomic) NSString *deviceRevision;
@property (readwrite, retain, nonatomic) NSString *busName;
@property (readwrite, retain, nonatomic) NSString *deviceVendor;
@property (readwrite, retain, nonatomic) NSString *volumeUUID;

- (NSDate *_Nullable)appearanceNSDate;

@end

NS_ASSUME_NONNULL_END
