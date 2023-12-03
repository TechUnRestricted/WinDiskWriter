//
//  NSWindow+Common.m
//  WinDiskWriter GUI
//
//  Created by Macintosh on 05.03.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "NSWindow+Common.h"

@implementation NSWindow (Common)

- (CGFloat) titlebarHeight {
    return self.frame.size.height - [self contentRectForFrameRect: self.frame].size.height;
}

@end
