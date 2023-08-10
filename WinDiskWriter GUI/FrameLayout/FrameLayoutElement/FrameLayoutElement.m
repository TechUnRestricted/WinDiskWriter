//
//  FrameLayoutElement.m
//  WinDiskWriter GUI
//
//  Created by Macintosh on 14.06.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "FrameLayoutElement.h"
#import "FrameLayoutBase.h"

@implementation FrameLayoutElement

- (instancetype)initWithNSView: (NSView *)nsView {
    self = [super init];
    
    _nsView = nsView;
    
    _paddingTop = 0;
    _paddingBottom = 0;
    _paddingLeft = 0;
    _paddingRight = 0;
    
    return self;
}

- (void)setPaddingTop:(CGFloat)paddingTop {
    _paddingTop = paddingTop;
    
    [self updateUI];
}

- (void)setPaddingBottom:(CGFloat)paddingBottom {
    _paddingBottom = paddingBottom;
    
    [self updateUI];
}

- (void)setPaddingLeft:(CGFloat)paddingLeft {
    _paddingLeft = paddingLeft;
    
    [self updateUI];
}

- (void)setPaddingRight:(CGFloat)paddingRight {
    _paddingRight = paddingRight;
    
    [self updateUI];
}

- (void)setPaddingTop: (CGFloat)paddingTop
        paddingBottom: (CGFloat)paddingBottom
          paddingLeft:(CGFloat)paddingLeft
         paddingRight:(CGFloat)paddingRight {
    
    _paddingTop = paddingTop;
    _paddingBottom = paddingBottom;
    _paddingLeft = paddingLeft;
    _paddingRight = paddingRight;
    
    [self updateUI];
}

- (CGFloat)canvasWidth {
    CGFloat firstValue = (self.paddingLeft >= 0 ? self.paddingLeft : 0);
    CGFloat secondValue = (self.paddingRight >= 0 ? self.paddingRight : 0);
    
    return self.computedWidth + (firstValue + secondValue);
}

- (CGFloat)nsViewWidth {
    CGFloat firstValue = (self.paddingLeft < 0 ? self.paddingLeft : 0);
    CGFloat secondValue = (self.paddingRight < 0 ? self.paddingRight : 0);
    
    return self.computedWidth + (firstValue + secondValue);
}

- (void)updateUI {
    if ([self.nsView isKindOfClass:[FrameLayoutBase class]]) {
        [(FrameLayoutBase *)self.nsView setNeedsDisplay: YES];
    }
}

@end
