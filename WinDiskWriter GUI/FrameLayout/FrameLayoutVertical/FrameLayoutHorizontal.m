//
//  FrameLayoutHorizontal.m
//  WinDiskWriter GUI
//
//  Created by Macintosh on 03.07.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "FrameLayoutHorizontal.h"

@implementation FrameLayoutHorizontal

- (NSUInteger)sortedIndexForValue:(CGFloat)value {
    NSUInteger low = 0;
    NSUInteger high = self.sortedElementsArray.count;

    while (low < high) {
        NSInteger mid = (low + high) / 2;
        if ([self.sortedElementsArray objectAtIndex:mid].maxWidth < value) {
            low = mid + 1;
        } else {
            high = mid;
        }
    }

    return low;
}

@end
