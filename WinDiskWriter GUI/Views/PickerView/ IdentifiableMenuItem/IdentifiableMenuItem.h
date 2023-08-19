//
//  IdentifiableMenuItem.h
//  WinDiskWriter GUI
//
//  Created by Macintosh on 19.08.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface IdentifiableMenuItem : NSMenuItem

@property (strong, nonatomic, readwrite) id userIdentifiableData;

- (instancetype)initWithTitle: (NSString *)title
         identifiableUserData: (id)identifiableUserData;

- (instancetype)initWithDeviceVendor: (NSString *)deviceVendor
                         deviceModel: (NSString *)deviceModel
              storageCapacityInBytes: (NSUInteger)storageCapacityInBytes
                             bsdName: (NSString *)bsdName;

@end

NS_ASSUME_NONNULL_END
