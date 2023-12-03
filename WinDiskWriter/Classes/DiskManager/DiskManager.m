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
#import "NSError+Common.h"

@implementation DiskManager {
    DASessionRef diskSession;
    DADiskRef currentDisk;
}

- (void)initDiskSession {
    diskSession = DASessionCreate(kCFAllocatorDefault);
}

- (void)dealloc {
    if (diskSession != NULL) {
        CFRelease(diskSession);
    }
    
    if (currentDisk != NULL) {
        CFRelease(currentDisk);
    }
}

- (instancetype _Nullable)initWithBSDName: (NSString *)bsdName {
    self = [super init];
    
    [self initDiskSession];
    
    currentDisk = DADiskCreateFromBSDName(kCFAllocatorDefault, diskSession, [bsdName UTF8String]);
    
    if (currentDisk == NULL) {
        return NULL;
    }
    
    return self;
}

- (instancetype _Nullable)initWithVolumePath: (NSString *)volumePath {
    self = [super init];
    
    [self initDiskSession];
    
    currentDisk = DADiskCreateFromVolumePath(kCFAllocatorDefault, diskSession, (CFURLRef)[NSURL fileURLWithPath:volumePath]);
    
    if (currentDisk == NULL) {
        return NULL;
    }
    
    return self;
}

+ (NSArray *)BSDDrivesNames {
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

+ (NSError *_Nullable)errorFromDADiskReturn: (DAReturn)daReturn {
    NSString *errorMessage;
    
    switch (daReturn) {
        case kDAReturnSuccess:
            return NULL;
        case kDAReturnError:
            errorMessage = @"An unspecified error occurred.";
            break;
        case kDAReturnBusy:
            errorMessage = @"The disk is busy and cannot be unmounted.";
            break;
        case kDAReturnBadArgument:
            errorMessage = @"An invalid argument was passed to the function.";
            break;
        case kDAReturnExclusiveAccess:
            errorMessage = @"The disk is locked and cannot be modified.";
            break;
        case kDAReturnNoResources:
            errorMessage = @"There are not enough resources to complete the operation.";
            break;
        case kDAReturnNotFound:
            errorMessage = @"The disk or the volume was not found.";
            break;
        case kDAReturnNotMounted:
            errorMessage = @"The volume is not mounted.";
            break;
        case kDAReturnNotPermitted:
            errorMessage = @"The operation is not permitted.";
            break;
        case kDAReturnNotPrivileged:
            errorMessage = @"The user does not have the required privileges.";
            break;
        case kDAReturnNotReady:
            errorMessage = @"The disk is not ready.";
            break;
        case kDAReturnNotWritable:
            errorMessage = @"The disk or the volume is not writable.";
            break;
        case kDAReturnUnsupported:
            errorMessage = @"The operation is not supported by the disk or the volume.";
            break;
        default:
            errorMessage = @"An unknown error occurred.";
            break;
    }
    
    return [NSError errorWithStringValue: errorMessage];
}

- (BOOL)unmountDiskWithOptions: (DADiskUnmountOptions)options
                         error: (NSError *_Nullable *_Nullable)error {
    struct CallbackWrapper callbackWrapper;
    callbackWrapper.semaphore = dispatch_semaphore_create(0);
    
    dispatch_queue_t dispatchDiskQueue = dispatch_queue_create("Unmount Disk Queue", NULL);
    
    DADiskUnmount(currentDisk, options, daDiskCallback, &callbackWrapper);
    DASessionSetDispatchQueue(diskSession, dispatchDiskQueue);
    dispatch_semaphore_wait(callbackWrapper.semaphore, DISPATCH_TIME_FOREVER);
    
    NSError *localError = [DiskManager errorFromDADiskReturn: callbackWrapper.daReturn];
    if (error) {
        *error = localError;
    }
    
    return localError == NULL;
}

- (BOOL)mountDiskWithOptions: (DADiskMountOptions)options
                           error: (NSError *_Nullable *_Nullable)error {
    struct CallbackWrapper callbackWrapper;
    callbackWrapper.semaphore = dispatch_semaphore_create(0);
    
    dispatch_queue_t dispatchDiskQueue = dispatch_queue_create("Mount Disk Queue", NULL);
    
    DADiskMount(currentDisk, NULL, options, daDiskCallback, &callbackWrapper);
    DASessionSetDispatchQueue(diskSession, dispatchDiskQueue);
    dispatch_semaphore_wait(callbackWrapper.semaphore, DISPATCH_TIME_FOREVER);
    
    NSError *localError = [DiskManager errorFromDADiskReturn: callbackWrapper.daReturn];
    if (error) {
        *error = localError;
    }
    
    return localError == NULL;
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
    
    DiskInfo *diskInfo = [self diskInfo];
    if (diskInfo.BSDName == NULL) {
        if (error) {
            *error = [NSError errorWithStringValue: @"Specified BSD Name does not exist. Can't erase this volume."];
        }
        
        return NO;
    }
    
    NSException *eraseVolumeException = NULL;
    CommandLineData *commandLineData = [CommandLine execute: @"/usr/sbin/diskutil"
                                                  arguments: @[@"eraseVolume",
                                                               filesystem,
                                                               newName,
                                                               diskInfo.BSDName
                                                             ]
                                                  exception: &eraseVolumeException
    ];
    
    if (eraseVolumeException != NULL) {
        if (error) {
            NSString *exceptionErrorString = [NSString stringWithFormat: @"There was an unknown error while executing the command. (%@)", eraseVolumeException.reason];
            
            *error = [NSError errorWithStringValue: exceptionErrorString];
        }
        
        return NO;
    }
    
    if (commandLineData.terminationStatus == EXIT_SUCCESS) {
        return YES;
    } else {
        if (error) {
            *error = [NSError errorWithStringValue: [NSString stringWithFormat: @"An Error has occured while erasing the volume. [Filesystem: %@; New Label: %@; BSD Name: %@]",
                                                    filesystem,
                                                    newName,
                                                    diskInfo.BSDName]
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
    
    DiskInfo *diskInfo = [self diskInfo];
    if (diskInfo.BSDName == NULL) {
        if (error) {
            *error = [NSError errorWithStringValue: @"Specified BSD Name does not exist. Can't erase this volume."];
        }
        
        return NO;
    }
    
    NSException *eraseVolumeException = NULL;
    CommandLineData *commandLineData = [CommandLine execute: @"/usr/sbin/diskutil"
                                                  arguments: @[@"eraseDisk",
                                                               filesystem,
                                                               newName,
                                                               partitionScheme,
                                                               diskInfo.BSDName
                                                             ]
                                                  exception: &eraseVolumeException
    ];
    
    if (eraseVolumeException != NULL) {
        if (error) {
            NSString *exceptionErrorString = [NSString stringWithFormat: @"There was an unknown error while executing the command. (%@)", eraseVolumeException.reason];
            
            *error = [NSError errorWithStringValue: exceptionErrorString];
        }
        
        return NO;
    }
    
    if (commandLineData.terminationStatus == EXIT_SUCCESS) {
        return YES;
    }
    
    if (error) {
        NSString *errorPipeOutput;
        if (commandLineData.errorData) {
            errorPipeOutput = [[NSString alloc] initWithData:commandLineData.errorData encoding:NSUTF8StringEncoding];
        } else {
            errorPipeOutput = @"Can't retrieve the information from the command line error output pipe.";
        }
        
        *error = [NSError errorWithStringValue: [errorPipeOutput strip]];
    }
    
    return NO;
    
}

+ (BOOL)isBSDPath: (NSString *)path {
    return [path hasOneOfThePrefixes:@[
        @"disk", @"/dev/disk",
        @"rdisk", @"/dev/rdisk"
    ]];
}

- (DiskInfo *)diskInfo {
    DiskInfo *diskInfo = [[DiskInfo alloc] init];
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
