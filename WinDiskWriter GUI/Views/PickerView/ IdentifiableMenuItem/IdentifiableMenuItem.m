//
//  IdentifiableMenuItem.m
//  WinDiskWriter GUI
//
//  Created by Macintosh on 19.08.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "IdentifiableMenuItem.h"
#import "NSMutableAttributedString+Common.h"
#import "HelperFunctions.h"

@implementation IdentifiableMenuItem

- (instancetype)initWithTitle: (NSString *)title
         identifiableUserData: (id)identifiableUserData {
    self = [super init];
    
    [self setTitle: title];
    [self setUserIdentifiableData: identifiableUserData];

    return self;
}

- (instancetype)initWithDeviceVendor: (NSString *)deviceVendor
                         deviceModel: (NSString *)deviceModel
              storageCapacityInBytes: (NSUInteger)storageCapacityInBytes
                             bsdName: (NSString *)bsdName {
    self = [super init];

    NSMutableAttributedString *mutableAttributesStringResult = [NSMutableAttributedString attributedStringWithString: [NSString stringWithFormat:@"%@ %@", deviceVendor, deviceModel]
                                                                                                              weight: 6
                                                                                                                size: NSFont.systemFontSize];
    
    NSString *formattedStorageCapacity = [HelperFunctions unitFormattedSizeFor:storageCapacityInBytes];
    [mutableAttributesStringResult appendAttributedString: [NSMutableAttributedString attributedStringWithNormalFormatting:[NSString stringWithFormat:@" [%@]", formattedStorageCapacity]]];

    
    [mutableAttributesStringResult appendAttributedString: [NSMutableAttributedString attributedStringWithString: [NSString stringWithFormat:@" (%@)", bsdName]
                                                                                                          weight: 3
                                                                                                            size: NSFont.systemFontSize / 1.2]];
    
    [self setAttributedTitle: mutableAttributesStringResult];
    
    [self setUserIdentifiableData: bsdName];
    
    return self;
}

@end
