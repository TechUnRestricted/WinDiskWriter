//
//  LayoutElement.m
//  WinDiskWriter GUI
//
//  Created by Macintosh on 14.06.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "LayoutElement.h"

@implementation LayoutElement

- (instancetype)initWithNSView: (NSView * _Nonnull)nsView {
    self = [super init];
    
    _nsView = nsView;
    
    return self;
}

@end
