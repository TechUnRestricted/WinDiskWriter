//
//  DiskWriter.h
//  windiskwriter
//
//  Created by Macintosh on 26.01.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "Filesystems.h"
NS_ASSUME_NONNULL_BEGIN

@interface DiskWriter: NSObject

@property(nonatomic, nonnull) Filesystem filesystem;
// @property(nonatomic) bool eraseDestinationDevice UNAVAILABLE_ATTRIBUTE;

- (NSString * _Nullable)getMountedWindowsISO;
- (struct DiskInfo)getDestinationDiskInfo;

//- (NSString * _Nullable)getWindowsSourceMountPath: (NSString *)isoPath;

- (BOOL)writeWindowsISO;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithWindowsISO: (NSString * _Nonnull)windowsISO
                 destinationDevice: (NSString * _Nonnull)destinationDevice
                        filesystem: (Filesystem _Nonnull)filesystem;

@end

NS_ASSUME_NONNULL_END
