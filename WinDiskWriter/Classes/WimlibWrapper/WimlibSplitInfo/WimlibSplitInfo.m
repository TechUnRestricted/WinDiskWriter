//
//  WimlibSplitInfo.m
//  windiskwriter
//
//  Created by Macintosh on 31.08.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "WimlibSplitInfo.h"

@implementation WimlibSplitInfo

- (instancetype)initWithCallback: (WimLibWrapperSplitImageCallback)callback {
    self = [super init];
    
    _callback = callback;
    
    return self;
}

@end
