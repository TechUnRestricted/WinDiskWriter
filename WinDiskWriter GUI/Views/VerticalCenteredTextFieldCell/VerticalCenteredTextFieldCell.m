//
//  VerticalCenteredTextFieldCell.m
//  WinDiskWriter GUI
//
//  Created by Macintosh on 27.07.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "VerticalCenteredTextFieldCell.h"

@implementation VerticalCenteredTextFieldCell

- (instancetype)init {
    self = [super init];
    
    [self setUsesSingleLineMode:YES];
    
    return self;
}

- (NSRect)adjustedFrameToVerticallyCenterText:(NSRect)frame {
    CGFloat fontHeight = self.font.ascender - self.font.descender;
    
    NSInteger offset = floor((NSHeight(frame) - fontHeight) / 2.0);
    
    return NSInsetRect(frame, 0.0, offset);
}

- (void)editWithFrame: (NSRect)aRect
               inView: (NSView *)controlView
               editor: (NSText *)editor
             delegate: (id)delegate
                event: (NSEvent *)event {
    
    [super editWithFrame: [self adjustedFrameToVerticallyCenterText: aRect]
                  inView: controlView
                  editor: editor
                delegate: delegate
                   event: event];
    
}

- (void)selectWithFrame: (NSRect)aRect
                 inView: (NSView *)controlView
                 editor: (NSText *)editor
               delegate: (id)delegate
                  start: (NSInteger)start
                 length: (NSInteger)length {
    
    [super selectWithFrame: [self adjustedFrameToVerticallyCenterText: aRect]
                    inView: controlView
                    editor: editor
                  delegate: delegate
                     start: start
                    length: length];
    
}

- (void)drawInteriorWithFrame: (NSRect)frame
                       inView: (NSView *)view {
    
    [super drawInteriorWithFrame: [self adjustedFrameToVerticallyCenterText:frame]
                          inView: view];
    
}


@end
