//
//  PickerView.m
//  WinDiskWriter GUI
//
//  Created by Macintosh on 30.07.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "PickerView.h"
#import <objc/runtime.h>

@implementation PickerView

- (instancetype)init {
    self = [super init];
    
    [self setBezelStyle:NSBezelStyleTexturedRounded];
    
    return self;
}

@end
