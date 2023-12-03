//
//  DWProgress.m
//  WinDiskWriter GUI
//
//  Created by Macintosh on 27.08.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "DWProgress.h"

@implementation DWProgress

- (instancetype)initWithDWFile: (DWFile *)file {
    self = [super self];
    
    _file = file;
    
    return self;
}

@end
