//
//  IdentifiableMenuItem.h
//  WinDiskWriter GUI
//
//  Created by Macintosh on 19.08.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DiskInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface IdentifiableMenuItem : NSMenuItem

@property (strong, nonatomic, readwrite) DiskInfo *diskInfo;

- (instancetype)initWithDiskInfo: (DiskInfo *)diskInfo;

@end

NS_ASSUME_NONNULL_END
