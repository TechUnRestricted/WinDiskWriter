//
//  FrameLayoutElement.m
//  WinDiskWriter GUI
//
//  Created by Macintosh on 14.06.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "FrameLayoutElement.h"

@implementation FrameLayoutElement

- (instancetype)initWithNSView: (NSView *)nsView {
    self = [super init];
    
    _nsView = nsView;
    
    _paddingTop = 0;
    _paddingBottom = 0;
    _paddingLeft = 0;
    _paddingRight = 0;
    
    return self;
}

@end
