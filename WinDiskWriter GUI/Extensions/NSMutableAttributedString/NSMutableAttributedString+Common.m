//
//  NSAttributedString.m
//  WinDiskWriter GUI
//
//  Created by Macintosh on 21.08.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "NSMutableAttributedString+Common.h"

@implementation NSMutableAttributedString (Common)

+ (NSMutableAttributedString *)attributedStringWithString: (NSString *)string
                                                   weight: (NSInteger)weight
                                                     size: (CGFloat)size {
    
    // TODO: Need a better solution to the dumb Apple Initializers
    NSFont *_tempDummyFont = [NSFont systemFontOfSize: NSFont.systemFontSize];
    
    NSDictionary *attributes = @{
        NSFontAttributeName:  [NSFontManager.sharedFontManager
                               fontWithFamily: _tempDummyFont.fontName
                               traits: NSUnboldFontMask
                               weight: weight
                               size: size]
    };
    
    NSMutableAttributedString *result = [[NSMutableAttributedString alloc] initWithString: string
                                                                               attributes: attributes];
    
    return result;
}

+ (NSMutableAttributedString *)attributedStringWithNormalFormatting: (NSString *)string {
    NSDictionary *normalAttributes = @{NSFontAttributeName: [NSFont systemFontOfSize: NSFont.systemFontSize]};
    
    NSMutableAttributedString *result = [[NSMutableAttributedString alloc] initWithString: string
                                                                        attributes: normalAttributes];
    
    return result;
}

@end
