//
//  MainWindow.h
//  WinDiskWriter GUI
//
//  Created by Macintosh on 30.08.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "ModernWindow.h"
#import "AboutWindow.h"

NS_ASSUME_NONNULL_BEGIN

@interface MainWindow : ModernWindow

@property (readwrite, nonatomic) BOOL enabledUIState;
@property (readwrite, nonatomic) BOOL isScheduledForStop;

- (instancetype)initWithNSRect: (NSRect)nsRect
                         title: (NSString *)title
                       padding: (CGFloat)padding NS_UNAVAILABLE;

- (instancetype)initWithNSRect: (NSRect)nsRect
                         title: (NSString *)title
                       padding: (CGFloat)padding
        paddingIsTitleBarAware: (BOOL)paddingIsTitleBarAware
                   aboutWindow: (AboutWindow *)aboutWindow
                  quitMenuItem: (NSMenuItem *)quitMenuItem
                 closeMenuItem: (NSMenuItem *)closeMenuItem;

@end

NS_ASSUME_NONNULL_END
