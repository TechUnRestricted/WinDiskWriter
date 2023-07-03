//
//  FrameLayoutElement.m
//  WinDiskWriter GUI
//
//  Created by Macintosh on 14.06.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "FrameLayoutElement.h"

@implementation FrameLayoutElement

- (instancetype)initWithNSView: (NSView * _Nonnull)nsView {
    self = [super init];
    
    _nsView = nsView;
    
    return self;
}

@end
