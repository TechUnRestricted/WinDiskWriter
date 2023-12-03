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

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithContentRect: (NSRect)contentRect
                          styleMask: (NSWindowStyleMask)style
                            backing: (NSBackingStoreType)backingStoreType
                              defer: (BOOL)flag NS_UNAVAILABLE;

- (instancetype)initWithContentRect:(NSRect)contentRect
                          styleMask:(NSWindowStyleMask)style
                            backing:(NSBackingStoreType)backingStoreType
                              defer:(BOOL)flag
                             screen:(NSScreen *_Nullable)screen NS_UNAVAILABLE;

- (instancetype)initWithNSRect: (NSRect)nsRect
                         title: (NSString *_Nullable)title
                       padding: (CGFloat)padding
        paddingIsTitleBarAware: (BOOL)paddingIsTitleBarAware;

- (void)showWindow;

- (void)removeAttachedSheetWithReturnCode: (NSInteger)returnCode;

- (CGFloat)titlebarHeight;

- (void)setOnCloseSelector: (SEL)selector
                    target: (id)target;

@property (strong, nonatomic, readonly) NSView *containerView;

@end

NS_ASSUME_NONNULL_END
