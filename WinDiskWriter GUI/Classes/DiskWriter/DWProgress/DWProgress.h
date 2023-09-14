//
//  DWProgress.h
//  WinDiskWriter GUI
//
//  Created by Macintosh on 27.08.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DWFile.h"

NS_ASSUME_NONNULL_BEGIN

@interface DWProgress : NSObject

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithDWFile: (DWFile *)file;

@property (strong, nonatomic, readonly) DWFile *file;
@property (nonatomic, readwrite) UInt64 copiedBytes;

@end

NS_ASSUME_NONNULL_END
