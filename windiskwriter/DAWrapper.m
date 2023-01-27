//
//  DAWrapper.m
//  windiskwriter
//
//  Created by Macintosh on 27.01.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import <DiskArbitration/DiskArbitration.h>
#import <Foundation/Foundation.h>
#import "DAWrapper.h"
#import "DebugSystem.h"

@implementation DAWrapper {
    DASessionRef diskSession;
    DADiskRef currentDisk;
    struct DiskInfo diskInfo;
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
        [self initDiskInfo];
    }

    return self;
}

- (instancetype _Nullable)initWithVolumePath: (NSString * _Nonnull)volumePath {
    [self initDiskSession];
    currentDisk = DADiskCreateFromVolumePath(kCFAllocatorDefault, diskSession, (CFURLRef)[NSURL fileURLWithPath:volumePath]);
    
    if (currentDisk == NULL) {
        DebugLog(@"Can't create DADisk from Volume Path.");
    } else {
        DebugLog(@"Successfully created DADisk from Volume Path.");
        [self initDiskInfo];
    }
    
    return self;
}

- (void)initDiskInfo {
    NSDictionary *diskDescription = CFBridgingRelease(DADiskCopyDescription(currentDisk));
    
    diskInfo.isDrive = [[diskDescription objectForKey:@"DAMediaWhole"] boolValue];
    diskInfo.isInternal = [[diskDescription objectForKey:@"DADeviceInternal"] boolValue];
    diskInfo.isMountable = [[diskDescription objectForKey:@"DAVolumeMountable"] boolValue];
    diskInfo.isRemovable = [[diskDescription objectForKey:@"DAMediaRemovable"] boolValue];
    diskInfo.isDeviceUnit = [[diskDescription objectForKey:@"DADeviceUnit"] boolValue];
    diskInfo.isWritable = [[diskDescription objectForKey:@"DAMediaWritable"] boolValue];
    diskInfo.isBSDUnit = [[diskDescription objectForKey:@"DAMediaBSDUnit"] boolValue];
    diskInfo.isEncrypted = [[diskDescription objectForKey:@"DAMediaEncrypted"] boolValue];
    diskInfo.isNetworkVolume = [[diskDescription objectForKey:@"DAVolumeNetwork"] boolValue];
    diskInfo.isEjectable = [[diskDescription objectForKey:@"DAMediaEjectable"] boolValue];

    diskInfo.mediaSize = [diskDescription objectForKey:@"DAMediaSize"];
    diskInfo.blockSize = [diskDescription objectForKey:@"DAMediaBlockSize"];
    diskInfo.appearanceTime = [diskDescription objectForKey:@"DAAppearanceTime"];

    diskInfo.devicePath = [diskDescription objectForKey:@"DADevicePath"];
    diskInfo.deviceModel = [diskDescription objectForKey:@"DADeviceModel"];
    diskInfo.BSDName = [diskDescription objectForKey:@"DAMediaBSDName"];
    diskInfo.mediaKind = [diskDescription objectForKey:@"DAMediaKind"];
    diskInfo.mediaPath = [diskDescription objectForKey:@"DAMediaPath"];
    diskInfo.mediaName = [diskDescription objectForKey:@"DAMediaName"];
    diskInfo.mediaContent = [diskDescription objectForKey:@"DAMediaContent"];
    diskInfo.busPath = [diskDescription objectForKey:@"DABusPath"];
    diskInfo.deviceProtocol = [diskDescription objectForKey:@"DADeviceProtocol"];
    diskInfo.deviceRevision = [diskDescription objectForKey:@"DADeviceRevision"];
    diskInfo.busName = [diskDescription objectForKey:@"DABusName"];
    diskInfo.deviceVendor = [diskDescription objectForKey:@"DADeviceVendor"];
    
    /* EXC_BAD_ADDRESS */
    // diskInfo.uuid = CFBridgingRelease(CFUUIDCreateString(nil, (CFUUIDRef)[diskDescription objectForKey:@"DAVolumeUUID"]));
    
}

struct CallbackWrapper {
    dispatch_semaphore_t semaphore;
    DAReturn daReturn;
};

void unmountDiskCallback(DADiskRef disk, DADissenterRef dissenter, void *context) {
    struct CallbackWrapper *callbackWrapper = context;
    callbackWrapper->daReturn = DADissenterGetStatus(dissenter);
    dispatch_semaphore_signal(callbackWrapper->semaphore);
}

- (DAReturn)unmountDiskWithOptions: (DADiskOptions)options {
    struct CallbackWrapper callbackWrapper;
    callbackWrapper.semaphore = dispatch_semaphore_create(0);

    dispatch_queue_t unmountDiskQueue = dispatch_queue_create("Unmount Disk Queue", NULL);

    DADiskUnmount(currentDisk, options, unmountDiskCallback, &callbackWrapper);
    DASessionSetDispatchQueue(diskSession, unmountDiskQueue);
    dispatch_semaphore_wait(callbackWrapper.semaphore, DISPATCH_TIME_FOREVER);
  
    return callbackWrapper.daReturn;
}

- (struct DiskInfo) getDiskInfo {
    return diskInfo;
}

@end
