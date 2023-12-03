//
//  LabelView.m
//  WinDiskWriter GUI
//
//  Created by Macintosh on 05.03.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "LabelView.h"

@implementation LabelView

- (instancetype)init {
    self = [super init];
    
    [self setEditable: NO];
    [self setSelectable: NO];
    [self setBezeled: NO];
    [self setDrawsBackground: NO];

    return self;
}

@end
