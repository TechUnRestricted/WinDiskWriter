//
//  LabelView.m
//  WinDiskWriter GUI
//
//  Created by Macintosh on 05.03.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "LabelView.h"
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

@implementation LabelView {
    NSTrackingArea *trackingArea;
    
    SEL clickSelector;
    id clickTarget;
}

- (instancetype)init {
    self = [super init];
        
    [self setEditable: NO];
    [self setSelectable: NO];
    [self setBezeled: NO];
    [self setDrawsBackground: NO];
    
    return self;
}

- (BOOL)isClickActionRegistered {
    if (trackingArea == NULL) {
        return NO;
    }
    
    return [self.trackingAreas containsObject: trackingArea];
}

- (void)registerClickWithTarget: (id)target
                       selector: (SEL)selector {
    [self unregisterClickAction];
    
    clickSelector = selector;
    clickTarget = target;
    
    NSTrackingAreaOptions option = NSTrackingInVisibleRect | NSTrackingMouseEnteredAndExited | NSTrackingActiveInKeyWindow;
    trackingArea = [[NSTrackingArea alloc] initWithRect: self.bounds
                                                options: option
                                                  owner: self
                                               userInfo: NULL];
    
    [self addTrackingArea: trackingArea];
}

- (void)unregisterClickAction {
    if ([self isClickActionRegistered]) {
        [self removeTrackingArea: trackingArea];
    }
}

- (void)mouseEntered:(NSEvent *)event {
    [super mouseEntered: event];
    
    [self addCursorRect:[self bounds] cursor:[NSCursor pointingHandCursor]];
    [self resetCursorRects];
}


- (void)mouseDown:(NSEvent *)event {
    [super mouseDown: event];
        
    if ([self isClickActionRegistered]) {
        [clickTarget performSelector: clickSelector];
    }
}

@end
