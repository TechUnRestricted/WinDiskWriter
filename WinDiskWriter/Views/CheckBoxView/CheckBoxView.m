//
//  CheckBoxView.m
//  WinDiskWriter GUI
//
//  Created by Macintosh on 30.07.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "CheckBoxView.h"

@implementation CheckBoxView

- (instancetype)init {
    self = [super init];
        
    [self setButtonType: NSSwitchButton];
        
    return self;
}

@end
