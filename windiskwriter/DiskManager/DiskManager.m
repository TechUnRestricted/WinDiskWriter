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
#import "CommandLine.h"
#import "Constants.h"
#import "HelperFunctions.h"
#import "Filesystems/Filesystems.h"
#import "NSString+Common.h"

@implementation DiskManager {
    DASessionRef diskSession;
    DADiskRef currentDisk;
}

- (void)initDiskSession {
    diskSession = DASessionCreate(kCFAllocatorDefault);
}

- (instancetype _Nullable)initWithBSDName: (NSString * _Nonnull)bsdName {
    [self initDiskSession];
    currentDisk = DADiskCreateFromBSDName(kCFAllocatorDefault, diskSession, [bsdName UTF8String]);
    
    if (currentDisk == NULL) {
        return NULL;
    }
    
    return self;
}

- (instancetype _Nullable)initWithVolumePath: (NSString * _Nonnull)volumePath {
    [self initDiskSession];
    currentDisk = DADiskCreateFromVolumePath(kCFAllocatorDefault, diskSession, (CFURLRef)[NSURL fileURLWithPath:volumePath]);
    
    if (currentDisk == NULL) {
        return NULL;
    }
    
    return self;
}

+ (NSArray *)getBSDDrivesNames {
    io_iterator_t iterator = 0;
    
    CFDictionaryRef matching = IOServiceMatching(kIOServicePlane);
    
    IOServiceGetMatchingServices(kIOMasterPortDefault, matching, &iterator);
    io_object_t child = IOIteratorNext(iterator);
    
    NSMutableArray *BSDNames = [NSMutableArray array];
    while (child > 0) {
        CFTypeRef BSDNameAnyObject = IORegistryEntryCreateCFProperty(child, CFSTR("BSD Name"), kCFAllocatorDefault, kIORegistryIterateRecursively);
        
        if (BSDNameAnyObject != NULL) {
            NSString *BSDNameString = (__bridge NSString *)BSDNameAnyObject;
            
            if ([BSDNameString hasPrefix:@"disk"]) {
                [BSDNames addObject:BSDNameString];
            }
            
            CFRelease(BSDNameAnyObject);
        }
        
        child = IOIteratorNext(iterator);
    }

    return BSDNames;
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

// TODO: Merge base logic [diskUtilEraseVolumeWithFilesystem + diskUtilEraseDiskWithPartitionScheme]
- (BOOL)diskUtilEraseVolumeWithFilesystem: (Filesystem)filesystem
                                  newName: (NSString * _Nullable)newName
                                    error: (NSError *_Nullable *_Nullable)error {
    
    if (newName == NULL) {
        /* New Name was not specified in diskUtilEraseVolumeWithFilesystem. Generating random NSString. */
        newName = [HelperFunctions randomStringWithLength:11];
    } else {
        newName = [newName uppercaseString];
    }
    
    struct DiskInfo diskInfo = [self getDiskInfo];
    if (diskInfo.BSDName == NULL) {
        if (error) {
            *error = [NSError errorWithDomain: PACKAGE_NAME
                                         code: DMErrorCodeSpecifiedBSDNameDoesNotExist
                                     userInfo: @{DEFAULT_ERROR_KEY:
                                                     @"Specified BSD Name does not exist. Can't erase this volume."}];
        }
        return NO;
    }
    
    struct CommandLineReturn commandLineReturn = [CommandLine execute:@"/usr/sbin/diskutil"
                                                            arguments:@[@"eraseVolume",
                                                                        filesystem,
                                                                        newName,
                                                                        diskInfo.BSDName
                                                                      ]
    ];
    
    if (commandLineReturn.terminationStatus == EXIT_SUCCESS) {
        return YES;
    } else {
        if (error) {
            *error = [NSError errorWithDomain: PACKAGE_NAME
                                         code: DMErrorCodeEraseDiskFailure
                                     userInfo: @{DEFAULT_ERROR_KEY: [NSString stringWithFormat: @"An Error has occured while erasing the volume. [Filesystem: %@; New Label: %@; BSD Name: %@]",
                                                                     filesystem,
                                                                     newName,
                                                                     diskInfo.BSDName]}
            ];
        }
        return NO;
    }
    
    
}

- (BOOL)diskUtilEraseDiskWithPartitionScheme: (PartitionScheme _Nonnull)partitionScheme
                                  filesystem: (Filesystem _Nonnull)filesystem
                                     newName: (NSString * _Nullable)newName
                                       error: (NSError *_Nullable *_Nullable)error {
    if (newName == NULL) {
        /* New Name was not specified in diskUtilEraseDiskWithPartitionScheme. Generating random NSString */
        newName = [HelperFunctions randomStringWithLength:11];
    } else {
        newName = [newName uppercaseString];
    }
    
    struct DiskInfo diskInfo = [self getDiskInfo];
    if (diskInfo.BSDName == NULL) {
        if (error) {
            *error = [NSError errorWithDomain: PACKAGE_NAME
                                         code: DMErrorCodeSpecifiedBSDNameDoesNotExist
                                     userInfo: @{DEFAULT_ERROR_KEY:
                                                     @"Specified BSD Name does not exist. Can't erase this volume."}
            ];
        }
        return NO;
    }
    
    struct CommandLineReturn commandLineReturn = [CommandLine execute:@"/usr/sbin/diskutil"
                                                            arguments:@[@"eraseDisk",
                                                                        filesystem,
                                                                        newName,
                                                                        partitionScheme,
                                                                        diskInfo.BSDName
                                                                      ]
    ];
    
    if (commandLineReturn.terminationStatus == EXIT_SUCCESS) {
        return YES;
    } else {
        if (error) {
            *error = [NSError errorWithDomain: PACKAGE_NAME
                                         code: DMErrorCodeEraseDiskFailure
                                     userInfo: @{DEFAULT_ERROR_KEY: [NSString stringWithFormat:@"An Error has occured while erasing the Disk. [Filesystem: %@; Partition Scheme: %@; New Label: %@; BSD Name: %@]",
                                                                     filesystem,
                                                                     partitionScheme,
                                                                     newName,
                                                                     diskInfo.BSDName]}
            ];
        }
        return NO;
    }
}

+ (BOOL) isBSDPath: (NSString *)path {
    return [path hasOneOfThePrefixes:@[
        @"disk", @"/dev/disk",
        @"rdisk", @"/dev/rdisk"
    ]];
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
