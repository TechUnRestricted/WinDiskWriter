//
//  DiskWriter.h
//  windiskwriter
//
//  Created by Macintosh on 26.01.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#ifndef DiskWriter_h
#define DiskWriter_h

#import "FileSystems.h"

@interface DiskWriter: NSObject {
    NSString *_mountedWindowsISO;
    NSString *_destinationDevice;
}

@property(nonatomic) enum FileSystems fileSystem;
@property(nonatomic) bool doNotErase;

- (NSString *)getMountedWindowsISO;
- (NSString *)getDestinationDevice;

+ (NSString *)getWindowsSourceMountPath: (NSString *)isoPath;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithWindowsISO: (NSString *)mountedWindowsISO
                 destinationDevice: (NSString *)destinationDevice;

@end

#endif /* DiskWriter_h */
