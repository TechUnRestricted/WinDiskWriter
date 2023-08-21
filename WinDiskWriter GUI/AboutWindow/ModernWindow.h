//
//  ModernWindow.h
//  WinDiskWriter GUI
//
//  Created by Macintosh on 21.08.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface ModernWindow : NSWindow

- (instancetype)initWithNSRect: (NSRect)nsRect
                         title: (NSString *)title
                       padding: (CGFloat)padding;

- (void)showWindow;

- (CGFloat)titlebarHeight;

@property (strong, nonatomic, readonly) NSView *containerView;

@end

NS_ASSUME_NONNULL_END
