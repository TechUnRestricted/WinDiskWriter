//
//  AboutWindow.m
//  WinDiskWriter GUI
//
//  Created by Macintosh on 21.08.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "AboutWindow.h"
#import "FrameLayout.h"

@implementation AboutWindow

- (instancetype)initWithNSRect: (NSRect)nsRect
                         title: (NSString *)title
                       padding: (CGFloat)padding {
    self = [super initWithNSRect: nsRect
                           title: title
                         padding: padding];
    
    [self setupViews];
    
    return self;
}

- (void)setupViews {
    FrameLayoutVertical *mainVerticalLayout = (FrameLayoutVertical *)self.containerView;
    
    
}

@end
