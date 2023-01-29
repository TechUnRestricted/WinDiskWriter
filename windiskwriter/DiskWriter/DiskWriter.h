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

@property(nonatomic, nonnull) Filesystem fileSystem;
@property(nonatomic) bool doNotErase;

- (NSString *)getMountedWindowsISO;
- (struct DiskInfo)getDestinationDiskInfo;

//- (NSString * _Nullable)getWindowsSourceMountPath: (NSString *)isoPath;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithWindowsISO: (NSString *)windowsISO
                 destinationDevice: (NSString *)destinationDevice
                        filesystem: (Filesystem)filesystem;

@end

NS_ASSUME_NONNULL_END
