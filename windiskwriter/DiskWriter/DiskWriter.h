//
//  DiskWriter.h
//  windiskwriter
//
//  Created by Macintosh on 26.01.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "BootModes.h"

NS_ASSUME_NONNULL_BEGIN
@interface DiskWriter: NSObject

- (BOOL)writeWindowsISO;

- (instancetype)init NS_UNAVAILABLE;
+ (BOOL)writeWindowsISOWithSourcePath: (NSString * _Nonnull)sourcePath
                      destinationPath: (NSString * _Nonnull)destinationPath
   bypassTPMAndSecureBootRequirements: (BOOL)bypassTPMAndSecureBootRequirements
                             bootMode: (BootMode)bootMode
                              isFAT32: (BOOL)isFAT32;

@end

NS_ASSUME_NONNULL_END
