//
//  NSColor+Common.m
//  ObjectiveC
//
//  Created by Macintosh on 26.02.2023.
//

#import "NSColor+Common.h"

@implementation NSColor(Common)

- (CGColorRef)toCGColor {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    NSColor* selfCopy = [self colorUsingColorSpaceName: NSDeviceRGBColorSpace];
    
    CGFloat colorValues[4];
    [selfCopy getRed: &colorValues[0]
               green: &colorValues[1]
                blue: &colorValues[2]
               alpha: &colorValues[3]
    ];
    
    CGColorRef color = CGColorCreate(colorSpace, colorValues);
    
    CGColorSpaceRelease(colorSpace);
    
    return color;
}

@end
