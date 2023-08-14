//
//  HelperFunctions.h
//  windiskwriter
//
//  Created by Macintosh on 27.01.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DiskManager.h"

NS_ASSUME_NONNULL_BEGIN

#define IOLog(FORMAT, ...) fprintf(stderr,"%s\n", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);

enum ImageMountError {
    ImageMountErrorFileDoesNotExist,
    ImageMountErrorFileIsNotISO
};

enum DestinationDeviceError {
    DestinationDeviceErrorBadPath,
    DestinationDeviceErrorUnsupportedAPICall,
    DestinationDeviceErrorInvalidBSDName
};

@interface HelperFunctions : NSObject
- (instancetype)init NS_UNAVAILABLE;
+ (void)printTimeElapsedWhenRunningCode: (NSString *)title
                              operation: (void (^)(void))operation;
+ (BOOL) hasElevatedRights;
+ (NSString *)randomStringWithLength: (UInt64)requiredLength;
+ (NSString *_Nullable)getWindowsSourceMountPath: (NSString *_Nonnull)sourcePath
                                           error: (NSError *_Nullable *_Nullable)error;
+ (DiskManager *_Nullable)getDiskManagerWithDevicePath: (NSString *)devicePath
                                           isBSDDevice: (BOOL *_Nullable)isBSDDevice
                                                 error: (NSError *_Nullable *_Nullable)error;
@end

NS_ASSUME_NONNULL_END
