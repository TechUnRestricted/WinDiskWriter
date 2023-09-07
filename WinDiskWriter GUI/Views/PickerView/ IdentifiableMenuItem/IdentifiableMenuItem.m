//
//  IdentifiableMenuItem.m
//  WinDiskWriter GUI
//
//  Created by Macintosh on 19.08.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "NSMutableAttributedString+Common.h"
#import "IdentifiableMenuItem.h"
#import "NSString+Common.h"
#import "HelperFunctions.h"

@implementation IdentifiableMenuItem

- (instancetype)initWithDiskInfo: (DiskInfo *)diskInfo {
    self = [super init];

    NSString *deviceVendor = [diskInfo.deviceVendor strip];
    NSString *deviceModel = [diskInfo.deviceModel strip];
    NSString *bsdName = diskInfo.BSDName;
    
    UInt64 storageCapacityInBytes = [diskInfo.mediaSize unsignedIntValue];
    
    NSMutableAttributedString *mutableAttributesStringResult = [NSMutableAttributedString attributedStringWithString: [NSString stringWithFormat:@"%@ %@", deviceVendor, deviceModel]
                                                                                                              weight: 6
                                                                                                                size: NSFont.systemFontSize];
    
    NSString *formattedStorageCapacity = [HelperFunctions unitFormattedSizeFor:storageCapacityInBytes];
    [mutableAttributesStringResult appendAttributedString: [NSMutableAttributedString attributedStringWithNormalFormatting:[NSString stringWithFormat:@" [%@]", formattedStorageCapacity]]];

    
    [mutableAttributesStringResult appendAttributedString: [NSMutableAttributedString attributedStringWithString: [NSString stringWithFormat:@" (%@)", bsdName]
                                                                                                          weight: 3
                                                                                                            size: NSFont.systemFontSize / 1.2]];
    
    [self setAttributedTitle: mutableAttributesStringResult];
    
    [self setDiskInfo: diskInfo];
    
    return self;
}

@end
