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
@property (strong, readonly, nonatomic) NSString *_Nonnull wimPath;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithWimPath: (NSString *)wimPath;

- (enum wimlib_error_code)splitWithDestinationDirectoryPath: (NSString * _Nonnull)destinationDirectoryPath
                                        maxSliceSizeInBytes: (UInt64 * _Nonnull)maxSliceSizeInBytes
                                            progressHandler: (wimlib_progress_func_t _Nullable)progressHandler
                                                    context: (void *_Nullable)context;

- (enum wimlib_error_code)extractFiles: (NSArray *)files
                  destinationDirectory: (NSString *)destinationDirectory;

- (BOOL)bypassWindowsSecurityChecks;

@end

NS_ASSUME_NONNULL_END
