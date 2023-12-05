//
//  SlideShowedLabelView.m
//  WinDiskWriter
//
//  Created by Macintosh on 05.12.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "SlideShowedLabelView.h"
#import <QuartzCore/QuartzCore.h>

@implementation SlideShowedLabelView {
    NSUInteger currentIndex;
    NSTimeInterval delayDuration;
    NSTimer *slideShowTimer;
}

- (instancetype)initWithStringArray: (NSArray<NSString *> *)stringArray
                      delayDuration: (NSTimeInterval)delayDuration {
    self = [super init];
    
    currentIndex = 0;
    self->delayDuration = delayDuration;

    _isSlideShowed = NO;
    _easeOutDuration = 1;
    _easeInDuration = 1;
    
    _stringArray = stringArray;
    
    if (_stringArray.count != 0) {
        [self setStringValue: _stringArray.firstObject];
    }
    
    return self;
}

- (void)timerAction {
    if (self.stringArray == NULL || [self.stringArray count] <= 1) {
        return;
    }
    
    currentIndex = (currentIndex + 1) % [self.stringArray count];
    
    NSString *currentStringValue = [self.stringArray objectAtIndex: currentIndex];
    [self setAnimatedStringValue: currentStringValue];
}

- (void)setIsSlideShowed: (BOOL)isSlideShowed {
    _isSlideShowed = isSlideShowed;
    
    if (isSlideShowed) {
        slideShowTimer = [NSTimer scheduledTimerWithTimeInterval: delayDuration
                                                          target: self
                                                        selector: @selector(timerAction)
                                                        userInfo: NULL
                                                         repeats: YES];
    } else {
        if (slideShowTimer != NULL) {
            [slideShowTimer invalidate];
        }
    }
}

- (void)setAnimatedStringValue: (NSString *)stringValue {
    if ([self.stringValue isEqualToString:stringValue]) {
        return;
    }
    
    if (@available(macOS 10.7, *)) {
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
            [context setDuration: self.easeOutDuration];
            [context setTimingFunction: [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseOut]];
            [self.animator setAlphaValue: 0.0];
        } completionHandler:^{
            [self setStringValue: stringValue];
            
            [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
                [context setDuration: self.easeInDuration];
                [context setTimingFunction: [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseIn]];
                [self.animator setAlphaValue: 1.0];
            } completionHandler: ^{}];
        }];
    } else {
        [self setStringValue: stringValue];
    }
}

@end
