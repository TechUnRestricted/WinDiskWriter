//
//  AppDelegate.m
//  WinDiskWriter GUI
//
//  Created by Macintosh on 13.06.2023.
//  Copyright © 2023 TechUnRestricted. All rights reserved.
//

#import "AppDelegate.h"
#import "NSString+Common.h"
#import "NSError+Common.h"

#import "Constants.h"

#import "AboutWindow.h"
#import "MainWindow.h"

@implementation AppDelegate {
    MainWindow *mainWindow;
    AboutWindow *aboutWindow;
    
    NSMenuItem* quitMenuItem;
}

- (void)setupMenuItems {
    NSMenu *menuBar = [[NSMenu alloc]init];
    [NSApp setMainMenu:menuBar];
    
    NSMenuItem *mainMenuBarItem = [[NSMenuItem alloc] init]; {
        [menuBar addItem:mainMenuBarItem];
        
        NSMenu *mainItemsMenu = [[NSMenu alloc]init]; {
            [mainMenuBarItem setSubmenu:mainItemsMenu];
            
            NSMenuItem* aboutMenuItem = [[NSMenuItem alloc] initWithTitle: MENU_ITEM_ABOUT_TITLE
                                                                   action: @selector(showAboutWindow)
                                                            keyEquivalent: @""]; {
                [mainItemsMenu addItem:aboutMenuItem];
            }
            
            [mainItemsMenu addItem: NSMenuItem.separatorItem];
            
            quitMenuItem = [[NSMenuItem alloc] initWithTitle: [NSString stringWithFormat: @"%@ %@", MENU_ITEM_QUIT_TITLE, APPLICATION_NAME]
                                                      action: NULL
                                               keyEquivalent: @"q"]; {
                [mainItemsMenu addItem:quitMenuItem];
            }
            
        }
    }
    
    NSMenuItem *editMenuBarItem = [[NSMenuItem alloc] init]; {
        [menuBar addItem:editMenuBarItem];
        
        NSMenu *editMenu = [[NSMenu alloc] initWithTitle: MENU_EDIT_TITLE]; {
            [editMenuBarItem setSubmenu:editMenu];
            
            NSMenuItem* cutMenuItem = [[NSMenuItem alloc] initWithTitle: MENU_ITEM_CUT_TITLE
                                                                 action: @selector(cut:)
                                                          keyEquivalent: @"x"]; {
                [editMenu addItem:cutMenuItem];
            }
            
            NSMenuItem* copyMenuItem = [[NSMenuItem alloc] initWithTitle: MENU_ITEM_COPY_TITLE
                                                                  action: @selector(copy:)
                                                           keyEquivalent: @"c"]; {
                [editMenu addItem:copyMenuItem];
            }
            
            NSMenuItem* pasteMenuItem = [[NSMenuItem alloc] initWithTitle: MENU_ITEM_PASTE_TITLE
                                                                   action: @selector(paste:)
                                                            keyEquivalent: @"v"]; {
                [editMenu addItem:pasteMenuItem];
            }
            
            NSMenuItem* selectAllMenuItem = [[NSMenuItem alloc] initWithTitle: MENU_ITEM_SELECT_ALL_TITLE
                                                                       action: @selector(selectAll:)
                                                                keyEquivalent: @"a"]; {
                [editMenu addItem:selectAllMenuItem];
            }
        }
        
    }
    
    NSMenuItem *windowMenuBarItem = [[NSMenuItem alloc] init]; {
        [menuBar addItem:windowMenuBarItem];
        
        NSMenu *windowMenu = [[NSMenu alloc] initWithTitle: MENU_WINDOW_TITLE]; {
            [windowMenuBarItem setSubmenu:windowMenu];
            
            NSMenuItem* minimizeMenuItem = [[NSMenuItem alloc] initWithTitle: MENU_MINIMIZE_TITLE
                                                                      action: @selector(miniaturize:)
                                                               keyEquivalent: @"m"]; {
                [windowMenu addItem:minimizeMenuItem];
            }
            
            NSMenuItem* hideMenuItem = [[NSMenuItem alloc] initWithTitle: MENU_HIDE_TITLE
                                                                  action: @selector(hide:)
                                                           keyEquivalent: @"h"]; {
                [windowMenu addItem:hideMenuItem];
            }
        }
    }
    
}

- (void)setupWindows {
    {
        NSSize minWindowSize = CGSizeMake(300, 450);
        NSSize maxWindowSize = CGSizeMake(360, 560);
        
        aboutWindow = [[AboutWindow alloc] initWithNSRect: CGRectMake(0, 0, minWindowSize.width, minWindowSize.height)
                                                    title: [NSString stringWithFormat:@"%@ %@", MENU_ITEM_ABOUT_TITLE, APPLICATION_NAME]
                                                  padding: CHILD_CONTENT_SPACING * 2
                                   paddingIsTitleBarAware: YES];
        
        [aboutWindow setMinSize: minWindowSize];
        [aboutWindow setMaxSize: maxWindowSize];
    }
    
    {
        NSSize minWindowSize = CGSizeMake(330, 555);
        NSSize maxWindowSize = CGSizeMake(500, 650);
        
        mainWindow = [[MainWindow alloc] initWithNSRect: CGRectMake(0, 0, minWindowSize.width, minWindowSize.height)
                                                  title: APPLICATION_NAME
                                                padding: CHILD_CONTENT_SPACING
                                 paddingIsTitleBarAware: YES
                                            aboutWindow: aboutWindow
                                           quitMenuItem: quitMenuItem];
        
        [mainWindow setMinSize: minWindowSize];
        [mainWindow setMaxSize: maxWindowSize];
    }
}

- (void)showAboutWindow {
    [aboutWindow showWindow];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self setupMenuItems];
    [self setupWindows];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return NO;
}

@end
