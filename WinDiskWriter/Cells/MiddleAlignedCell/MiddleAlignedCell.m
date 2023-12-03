//
//  MiddleAlignedCell.m
//  WinDiskWriter GUI
//
//  Created by Macintosh on 03.12.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "MiddleAlignedCell.h"

@implementation MiddleAlignedCell

- (instancetype)init {
    self = [super init];
        
    return self;
}

- (NSRect)titleRectForBounds:(NSRect)theRect {
    NSRect titleFrame = [super titleRectForBounds: theRect];
    NSSize titleSize = [self.attributedStringValue size];
    
    titleFrame.origin.y = theRect.origin.y - 0.5 + (theRect.size.height - titleSize.height) / 2.0;
    
    return titleFrame;
}

- (void)drawInteriorWithFrame: (NSRect)cellFrame
                       inView: (NSView *)controlView {
    NSRect titleRect = [self titleRectForBounds: cellFrame];
    
    [self.attributedStringValue drawInRect: titleRect];
}

@end
