//
//  WimlibWrapper.h
//  windiskwriter
//
//  Created by Macintosh on 12.02.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "wimlib.h"

NS_ASSUME_NONNULL_BEGIN

@interface WimlibWrapper : NSObject

typedef NS_ENUM(NSUInteger, WimlibWrapperResult) {
    WimlibWrapperResultSuccess,
    WimlibWrapperResultFailure,
    WimlibWrapperResultSkipped
};

typedef NS_ENUM(NSInteger, WimLibWrapperCPUArch) {
    WimLibWrapperCPUArchUnknown = -1,
    WimLibWrapperCPUArchIntel = 0,
    WimLibWrapperCPUArchMIPS = 1,
    WimLibWrapperCPUArchAlpha = 2,
    WimLibWrapperCPUArchPPC = 3,
    WimLibWrapperCPUArchSHX = 4,
    WimLibWrapperCPUArchARM = 5,
    WimLibWrapperCPUArchIA64 = 6,
    WimLibWrapperCPUArchAlpha64 = 7,
    WimLibWrapperCPUArchMSIL = 8,
    WimLibWrapperCPUArchAMD64 = 9,
    WimLibWrapperCPUArchIA32OnWin64 = 10,
    WimLibWrapperCPUArchARM64 = 12,
};

@property (strong, readonly, nonatomic) NSString *_Nonnull wimPath;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithWimPath: (NSString *)wimPath;

- (UInt32)imagesCount;

- (NSString *_Nullable)propertyValueForKey: (NSString *)key
                                imageIndex: (UInt32)imageIndex;

- (WimlibWrapperResult)setPropertyValue: (NSString *)value
                                 forKey: (NSString *)key
                             imageIndex: (UInt32)imageIndex;

- (WimlibWrapperResult)setPropertyValueForAllImages: (NSString *)value
                                             forKey: (NSString *)key;

- (BOOL)applyChanges;

- (enum wimlib_error_code)splitWithDestinationDirectoryPath: (NSString *)destinationDirectoryPath
                                        maxSliceSizeInBytes: (UInt64 *)maxSliceSizeInBytes
                                            progressHandler: (wimlib_progress_func_t _Nullable)progressHandler
                                                    context: (void *_Nullable)context;

- (BOOL)extractFiles: (NSArray *)files
destinationDirectory: (NSString *)destinationDirectory
      fromImageIndex: (UInt32)imageIndex;

- (WimlibWrapperResult)extractWindowsEFIBootloaderForDestinationDirectory: (NSString *)destinationDirectory;

- (WimlibWrapperResult)patchWindowsRequirementsChecks;

@end

NS_ASSUME_NONNULL_END
