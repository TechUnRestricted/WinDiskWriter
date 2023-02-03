//
//  DAWrapper.m
//  windiskwriter
//
//  Created by Macintosh on 27.01.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import <DiskArbitration/DiskArbitration.h>
#import <Foundation/Foundation.h>
#import "DiskManager.h"
#import "DebugSystem.h"
#import "CommandLine.h"
#import "HelperFunctions.h"
#import "Filesystems/Filesystems.h"

@implementation DiskManager {
    DASessionRef diskSession;
    DADiskRef currentDisk;
    //struct DiskInfo diskInfo;
}

- (void)initDiskSession {
    diskSession = DASessionCreate(kCFAllocatorDefault);
}

- (instancetype _Nullable)initWithBSDName: (NSString * _Nonnull)bsdName {
    [self initDiskSession];
    currentDisk = DADiskCreateFromBSDName(kCFAllocatorDefault, diskSession, [bsdName UTF8String]);
    
    if (currentDisk == NULL) {
        DebugLog(@"Can't create DADisk from BSD Name.");
    } else {
        DebugLog(@"Successfully created DADisk from BSD Name.");
        // [self initDiskInfo];
    }

    return self;
}

- (instancetype _Nullable)initWithVolumePath: (NSString * _Nonnull)volumePath {
    [self initDiskSession];
    currentDisk = DADiskCreateFromVolumePath(kCFAllocatorDefault, diskSession, (CFURLRef)[NSURL fileURLWithPath:volumePath]);
    
    if (currentDisk == NULL) {
        DebugLog(@"Can't create DADisk from Volume Path.");
        return NULL;
    } else {
        DebugLog(@"Successfully created DADisk from Volume Path.");
    }
    
    return self;
}

struct CallbackWrapper {
    dispatch_semaphore_t semaphore;
    DAReturn daReturn;
};

void daDiskCallback(DADiskRef disk, DADissenterRef dissenter, void *context) {
    struct CallbackWrapper *callbackWrapper = context;
    
    if (dissenter != NULL) {
        callbackWrapper->daReturn = DADissenterGetStatus(dissenter);
    } else {
        callbackWrapper->daReturn = kDAReturnSuccess;
    }
    
    dispatch_semaphore_signal(callbackWrapper->semaphore);
}

- (DAReturn)unmountDiskWithOptions: (DADiskUnmountOptions)options {
    struct CallbackWrapper callbackWrapper;
    callbackWrapper.semaphore = dispatch_semaphore_create(0);

    dispatch_queue_t dispatchDiskQueue = dispatch_queue_create("Unmount Disk Queue", NULL);

    DADiskUnmount(currentDisk, options, daDiskCallback, &callbackWrapper);
    DASessionSetDispatchQueue(diskSession, dispatchDiskQueue);
    dispatch_semaphore_wait(callbackWrapper.semaphore, DISPATCH_TIME_FOREVER);
    
    return callbackWrapper.daReturn;
}

- (DAReturn)mountDiskWithOptions: (DADiskMountOptions)options {
    struct CallbackWrapper callbackWrapper;
    callbackWrapper.semaphore = dispatch_semaphore_create(0);

    dispatch_queue_t dispatchDiskQueue = dispatch_queue_create("Mount Disk Queue", NULL);

    DADiskMount(currentDisk, NULL, options, daDiskCallback, &callbackWrapper);
    DASessionSetDispatchQueue(diskSession, dispatchDiskQueue);
    dispatch_semaphore_wait(callbackWrapper.semaphore, DISPATCH_TIME_FOREVER);
  
    return callbackWrapper.daReturn;
}

- (BOOL)diskUtilEraseVolumeWithFilesystem: (Filesystem)filesystem
                                  newName: (NSString * _Nullable)newName {
    if (newName == NULL) {
        newName = [HelperFunctions randomStringWithLength:11];
        DebugLog(@"New Name was not specified in diskUtilEraseVolumeWithFilesystem. Generating random NSString: [ %@ ].", newName);
    } else {
        newName = [newName uppercaseString];
    }
    
    struct DiskInfo diskInfo = [self getDiskInfo];
    if (diskInfo.BSDName == NULL) {
        DebugLog(@"Specified BSD Name does not exist. Can't erase this volume.");
        return NO;
    }
    
    struct CommandLineReturn commandLineReturn = [CommandLine execute:@"/usr/sbin/diskutil"
                                                        withArguments:@[@"eraseVolume",
                                                                        filesystem,
                                                                        newName,
                                                                        diskInfo.BSDName
                                                                      ]
    ];
    
    if (commandLineReturn.terminationStatus == EXIT_SUCCESS) {
        DebugLog(@"Successfully erased volume. [Filesystem: %@; New Label: %@; BSD Name: %@]",
                 filesystem,
                 newName,
                 diskInfo.BSDName
        );
        return YES;
    } else {
        DebugLog(@"An Error has occured while erasing the volume. [Filesystem: %@; New Label: %@; BSD Name: %@]",
                 filesystem,
                 newName,
                 diskInfo.BSDName
        );
    }

    return NO;
}

- (BOOL)diskUtilEraseDiskWithPartitionScheme: (PartitionScheme _Nonnull)partitionScheme
                                  filesystem: (Filesystem _Nonnull)filesystem
                                     newName: (NSString * _Nullable)newName {
   if (newName == NULL) {
        newName = [HelperFunctions randomStringWithLength:11];
        DebugLog(@"New Name was not specified in diskUtilEraseDiskWithPartitionScheme. Generating random NSString: [ %@ ].", newName);
    } else {
        newName = [newName uppercaseString];
    }
    
    struct DiskInfo diskInfo = [self getDiskInfo];
    if (diskInfo.BSDName == NULL) {
        DebugLog(@"Specified BSD Name does not exist. Can't erase this volume.");
        return NO;
    }
    
    struct CommandLineReturn commandLineReturn = [CommandLine execute:@"/usr/sbin/diskutil"
                                                        withArguments:@[@"eraseDisk",
                                                                        filesystem,
                                                                        newName,
                                                                        partitionScheme,
                                                                        diskInfo.BSDName
                                                                      ]
    ];
    
    if (commandLineReturn.terminationStatus == EXIT_SUCCESS) {
        DebugLog(@"Successfully erased Disk. [Filesystem: %@; Partition Scheme: %@; New Label: %@; BSD Name: %@]",
                 filesystem,
                 partitionScheme,
                 newName,
                 diskInfo.BSDName
        );
        return YES;
    } else {
        DebugLog(@"An Error has occured while erasing the Disk. [Filesystem: %@; Partition Scheme: %@; New Label: %@; BSD Name: %@]",
                 filesystem,
                 partitionScheme,
                 newName,
                 diskInfo.BSDName
        );
    }

    return NO;
    
}

- (struct DiskInfo) getDiskInfo {
    struct DiskInfo diskInfo;
    NSDictionary *diskDescription = CFBridgingRelease(DADiskCopyDescription(currentDisk));
    
    diskInfo.isWholeDrive = [[diskDescription objectForKey:@"DAMediaWhole"] boolValue];
    diskInfo.isInternal = [[diskDescription objectForKey:@"DADeviceInternal"] boolValue];
    diskInfo.isMountable = [[diskDescription objectForKey:@"DAVolumeMountable"] boolValue];
    diskInfo.isRemovable = [[diskDescription objectForKey:@"DAMediaRemovable"] boolValue];
    diskInfo.isDeviceUnit = [[diskDescription objectForKey:@"DADeviceUnit"] boolValue];
    diskInfo.isWritable = [[diskDescription objectForKey:@"DAMediaWritable"] boolValue];
    diskInfo.isEncrypted = [[diskDescription objectForKey:@"DAMediaEncrypted"] boolValue];
    diskInfo.isNetworkVolume = [[diskDescription objectForKey:@"DAVolumeNetwork"] boolValue];
    diskInfo.isEjectable = [[diskDescription objectForKey:@"DAMediaEjectable"] boolValue];

    diskInfo.BSDUnit = [diskDescription objectForKey:@"DAMediaBSDUnit"];
    
    diskInfo.mediaSize = [diskDescription objectForKey:@"DAMediaSize"];
    diskInfo.mediaBSDMajor = [diskDescription objectForKey:@"DAMediaBSDMajor"];
    diskInfo.mediaBSDMinor = [diskDescription objectForKey:@"DAMediaBSDMinor"];

    diskInfo.blockSize = [diskDescription objectForKey:@"DAMediaBlockSize"];
    diskInfo.appearanceTime = [diskDescription objectForKey:@"DAAppearanceTime"];

    diskInfo.devicePath = [diskDescription objectForKey:@"DADevicePath"];
    diskInfo.deviceModel = [diskDescription objectForKey:@"DADeviceModel"];
    diskInfo.BSDName = [diskDescription objectForKey:@"DAMediaBSDName"];
    diskInfo.mediaKind = [diskDescription objectForKey:@"DAMediaKind"];
    diskInfo.volumeKind = [diskDescription objectForKey:@"DAVolumeKind"];
    diskInfo.volumeName = [diskDescription objectForKey:@"DAVolumeName"];
    diskInfo.volumePath = [diskDescription objectForKey:@"DAVolumePath"];
    diskInfo.mediaPath = [diskDescription objectForKey:@"DAMediaPath"];
    diskInfo.mediaName = [diskDescription objectForKey:@"DAMediaName"];
    diskInfo.mediaContent = [diskDescription objectForKey:@"DAMediaContent"];
    diskInfo.busPath = [diskDescription objectForKey:@"DABusPath"];
    diskInfo.deviceProtocol = [diskDescription objectForKey:@"DADeviceProtocol"];
    diskInfo.deviceRevision = [diskDescription objectForKey:@"DADeviceRevision"];
    diskInfo.busName = [diskDescription objectForKey:@"DABusName"];
    diskInfo.deviceVendor = [diskDescription objectForKey:@"DADeviceVendor"];

    id tempVolumeUUID = [diskDescription objectForKey:@"DAVolumeUUID"];    
    if (tempVolumeUUID != NULL) {
        diskInfo.volumeUUID = CFBridgingRelease(CFUUIDCreateString(nil, (CFUUIDRef)tempVolumeUUID));
    }
    
    return diskInfo;
}

@end
