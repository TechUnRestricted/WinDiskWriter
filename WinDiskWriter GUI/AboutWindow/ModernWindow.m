//
//  ModernWindow.m
//  WinDiskWriter GUI
//
//  Created by Macintosh on 21.08.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "ModernWindow.h"
#import "FrameLayout.h"

@implementation ModernWindow

- (CGFloat)titlebarHeight {
    if (@available(macOS 10.10, *)) {
        return self.contentView.frame.size.height - self.contentLayoutRect.size.height;
    }
    
    return 0;
}

- (instancetype)initWithNSRect: (NSRect)nsRect
                         title: (NSString *)title
                       padding: (CGFloat)padding {
    self = [super initWithContentRect: nsRect
                            styleMask: NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask
                              backing: NSBackingStoreBuffered
                                defer: NO];
    
    [self setMovableByWindowBackground: YES];
    [self setTitle: title];
    
    NSView *backgroundView;
    
    if (@available(macOS 10.10, *)) {
        [self setTitlebarAppearsTransparent: YES];
        self.styleMask |= NSWindowStyleMaskFullSizeContentView;
        
        NSVisualEffectView *visualEffectView = [[NSVisualEffectView alloc] initWithFrame:self.frame];
        
        [visualEffectView setState:NSVisualEffectStateActive];
        [visualEffectView setBlendingMode:NSVisualEffectBlendingModeBehindWindow];
        
        backgroundView = visualEffectView;
    } else {
        backgroundView = [[NSView alloc] init];
    }
    
    [self setContentView: backgroundView];
    
    [self setupMainVerticalViewWithPaddingTop: (padding / 2) + self.titlebarHeight 
                                       bottom: padding
                                         left: padding
                                        right: padding];
    
    return self;
}

- (void)showWindow {
    [self center];
    [self makeKeyAndOrderFront: NULL];
}

- (void)setupMainVerticalViewWithPaddingTop: (CGFloat)top
                                     bottom: (CGFloat)bottom
                                       left: (CGFloat)left
                                      right: (CGFloat)right {
    
    CGFloat x = left;
    CGFloat y = bottom;
    CGFloat width = self.contentView.frame.size.width - left - right;
    CGFloat height = self.contentView.frame.size.height - top - bottom;
    
    CGRect windowRect = CGRectMake(x, y, width, height);
    
    _containerView = [[FrameLayoutVertical alloc] initWithFrame: windowRect];
    
    [self.contentView addSubview:_containerView];
    
    
    [_containerView setAutoresizingMask: NSViewWidthSizable | NSViewHeightSizable];
    
    [(FrameLayoutBase *)_containerView setVerticalAlignment: FrameLayoutVerticalTop];
}



@end
