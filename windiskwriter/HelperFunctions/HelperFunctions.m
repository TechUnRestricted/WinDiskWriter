//
//  HelperFunctions.m
//  windiskwriter
//
//  Created by Macintosh on 27.01.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "HelperFunctions.h"
#import "NSString+Common.h"
#import "DiskManager.h"
#import "Constants.h"
#import "HDIUtil.h"

NSString const *MSDOSCompliantSymbols  = @"ABCDEFGHIJKLMNOPQRSTUVWXZY0123456789";

@implementation HelperFunctions

+ (BOOL) hasElevatedRights {
    return getuid() == 0;
}

+ (void)printTimeElapsedWhenRunningCode: (NSString *)title
                              operation: (void (^)(void))operation {
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    operation();
    CFAbsoluteTime timeElapsed = CFAbsoluteTimeGetCurrent() - startTime;
 
    NSLog(@"Time elapsed for %@: %f s.", title, timeElapsed);
}

+ (NSString *)randomStringWithLength: (UInt64)requiredLength {
    NSMutableString *generatedString = [NSMutableString stringWithCapacity:requiredLength];
    for (NSUInteger i = 0U; i < requiredLength; i++) {
        u_int32_t r = arc4random() % [MSDOSCompliantSymbols length];
        unichar c = [MSDOSCompliantSymbols characterAtIndex:r];
        [generatedString appendFormat:@"%C", c];
    }
    
    return generatedString;
}

+ (NSString *_Nullable)getWindowsSourceMountPath: (NSString *_Nonnull)sourcePath
                                           error: (NSError *_Nullable *_Nullable)error {
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    BOOL isDirectory;
    BOOL exists = [fileManager fileExistsAtPath:sourcePath isDirectory:&isDirectory];
    
    if (!exists) {
        if (error) {
            *error = [NSError errorWithDomain: PACKAGE_NAME
                                         code: ImageMountErrorFileDoesNotExist
                                     userInfo: @{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"File [directory] \"%@\" doesn't exist.", sourcePath]}
            ];
        }
        return NULL;
    }
    
    if (isDirectory) {
        return sourcePath;
    }
    
    if (![[[sourcePath lowercaseString] pathExtension] isEqualToString: @"iso"]) {
        if (error) {
            *error = [NSError errorWithDomain: PACKAGE_NAME
                                         code: ImageMountErrorFileIsNotISO
                                     userInfo: @{NSLocalizedDescriptionKey: @"This file does not have an .iso extension."}
            ];
        }
        return NULL;
    }
    
    HDIUtil *hdiutil = [[HDIUtil alloc] initWithImagePath:sourcePath];
    if([hdiutil attachImageWithArguments:@[@"-readonly", @"-noverify", @"-noautofsck", @"-noautoopen"]
                                   error: error]) {
        return [hdiutil getMountPoint];
    }
    
    return NULL;
}

+ (DiskManager *_Nullable)getDiskManagerWithDevicePath: (NSString *)devicePath
                                           isBSDDevice: (BOOL *_Nullable)isBSDDevice
                                                 error: (NSError *_Nullable *_Nullable)error {
    
    if ([DiskManager isBSDPath:devicePath]) {
        if (isBSDDevice != NULL) {
            *isBSDDevice = YES;
        }
        /* Received device destination path was defined as BSD Name. */
        return [[DiskManager alloc] initWithBSDName:devicePath];
    }
    else if ([devicePath hasPrefix:@"/Volumes/"]) {
        if (isBSDDevice != NULL) {
            *isBSDDevice = NO;
        }
        
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        BOOL isDirectory;
        BOOL exists = [fileManager fileExistsAtPath:devicePath isDirectory:&isDirectory];
        
        if (!exists) {
            if (error) {
                *error = [NSError errorWithDomain: PACKAGE_NAME
                                             code: DestinationDeviceErrorBadPath
                                         userInfo: @{NSLocalizedDescriptionKey: @"The given Destination path does not exist."}
                ];
            }
            return NULL;
        }
        
        /* Received device destination path was defined as Mounted Volume. */
        if (@available(macOS 10.7, *)) {
            return [[DiskManager alloc] initWithVolumePath:devicePath];
        } else {
            // TODO: Fix Mac OS X 10.6 Snow Leopard support
            if (error) {
                *error = [NSError errorWithDomain: PACKAGE_NAME
                                             code: DestinationDeviceErrorUnsupportedAPICall
                                         userInfo: @{NSLocalizedDescriptionKey: @"Can't load Destination device info from Mounted Volume on this Mac OS X version."}
                ];
            }
            return NULL;
        }
    }
    return NULL;
}

// TODO: Why it is a CGFloat? Change it to the NSUInteger!
+ (NSString *)unitFormattedSizeFor: (CGFloat)doubleBytes {
    NSArray *units = @[
        @"B", @"KB", @"MB", @"GB", @"TB", @"PB", @"EB"
    ];
    
    UInt8 unitPosition = 0;

    while (doubleBytes > 1000) {
        doubleBytes /= 1000;
        unitPosition += 1;
    }
    
    return [NSString stringWithFormat:@"%.2f %@",
            doubleBytes,
            [units objectAtIndex:unitPosition]
    ];
}

@end
