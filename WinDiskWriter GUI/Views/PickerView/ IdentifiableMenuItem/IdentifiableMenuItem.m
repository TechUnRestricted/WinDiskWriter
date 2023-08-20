//
//  IdentifiableMenuItem.m
//  WinDiskWriter GUI
//
//  Created by Macintosh on 19.08.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "IdentifiableMenuItem.h"
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

    // TODO: Need a better solution to the dumb Apple Initializers
    NSFont *_tempDummyFont = [NSFont systemFontOfSize: NSFont.systemFontSize];
    
    NSDictionary *boldAttributes = @{
        NSFontAttributeName:  [NSFontManager.sharedFontManager
                         fontWithFamily: _tempDummyFont.fontName
                         traits: NSUnboldFontMask
                         weight: 6
                         size: NSFont.systemFontSize]
    };
    
    NSDictionary *lightSmallAttributes = @{
        NSFontAttributeName:  [NSFontManager.sharedFontManager
                         fontWithFamily: _tempDummyFont.fontName
                         traits: NSUnboldFontMask
                         weight: 3
                         size: NSFont.systemFontSize / 1.2],
    };
    
    NSMutableAttributedString *mutableAttributedStringResult = [[NSMutableAttributedString alloc] initWithString: [NSString stringWithFormat:@"%@ %@", deviceVendor, deviceModel]
                                                                                                 attributes: boldAttributes];
    
    NSDictionary *normalAttributes = @{NSFontAttributeName: [NSFont systemFontOfSize: NSFont.systemFontSize]};
    
    NSString *formattedStorageCapacity = [HelperFunctions unitFormattedSizeFor:storageCapacityInBytes];

    [mutableAttributedStringResult appendAttributedString: [[NSMutableAttributedString alloc] initWithString: [NSString stringWithFormat:@" [%@]", formattedStorageCapacity]
                                                                                                  attributes: normalAttributes]];
    
    [mutableAttributedStringResult appendAttributedString: [[NSMutableAttributedString alloc] initWithString: [NSString stringWithFormat:@" (%@)", bsdName]
                                                                                                  attributes: lightSmallAttributes]];
    
    [self setAttributedTitle: mutableAttributedStringResult];
    
    [self setUserIdentifiableData: bsdName];
    
    return self;
}

@end
