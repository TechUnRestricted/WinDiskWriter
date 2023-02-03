//
//  DiskWriter.h
//  windiskwriter
//
//  Created by Macintosh on 26.01.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

@interface DiskWriter: NSObject

- (BOOL)writeWindowsISO;

- (instancetype)init NS_UNAVAILABLE;
+ (BOOL)writeWindows11ISOWithSourcePath: (NSString *)sourcePath
                        destinationPath: (NSString *)destinationPath
                  bypassTPMRequirements: (BOOL)bypassTPMAndSecureBootRequirements
                                isFAT32: (BOOL)isFAT32;

@end

NS_ASSUME_NONNULL_END
