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
#import "HelperFunctions.h"
#import "LocalizedStrings.h"

#import "Constants.h"

#import "AboutWindow.h"
#import "MainWindow.h"

@implementation AppDelegate {
    MainWindow *mainWindow;
    AboutWindow *aboutWindow;
    
    NSMenuItem *quitMenuItem;
    NSMenuItem *closeMenuItem;
}

- (void)setupMenuItems {
    NSMenu *menuBar = [[NSMenu alloc]init];
    [NSApp setMainMenu: menuBar];
    
    NSMenuItem *mainMenuBarItem = [[NSMenuItem alloc] init]; {
        [menuBar addItem:mainMenuBarItem];
        
        NSMenu *mainItemsMenu = [[NSMenu alloc] init]; {
            [mainMenuBarItem setSubmenu:mainItemsMenu];
            
            NSMenuItem *aboutMenuItem = [[NSMenuItem alloc] initWithTitle: [LocalizedStrings MENU_TITLE_ITEM_ABOUT]
                                                                   action: @selector(showAboutWindow)
                                                            keyEquivalent: @""]; {
                [mainItemsMenu addItem: aboutMenuItem];
            }
            
            [mainItemsMenu addItem: NSMenuItem.separatorItem];
            
            quitMenuItem = [[NSMenuItem alloc] initWithTitle: [NSString stringWithFormat: @"%@ %@", [LocalizedStrings MENU_TITLE_ITEM_QUIT], [Constants applicationName]]
                                                      action: NULL
                                               keyEquivalent: @"q"]; {
                [mainItemsMenu addItem:quitMenuItem];
            }
            
        }
    }
    
    NSMenuItem *editMenuBarItem = [[NSMenuItem alloc] init]; {
        [menuBar addItem:editMenuBarItem];
        
        NSMenu *editMenu = [[NSMenu alloc] initWithTitle: [LocalizedStrings MENU_TITLE_EDIT]]; {
            [editMenuBarItem setSubmenu: editMenu];
            
            NSMenuItem *cutMenuItem = [[NSMenuItem alloc] initWithTitle: [LocalizedStrings MENU_TITLE_ITEM_CUT]
                                                                 action: @selector(cut:)
                                                          keyEquivalent: @"x"]; {
                [editMenu addItem: cutMenuItem];
            }
            
            NSMenuItem *copyMenuItem = [[NSMenuItem alloc] initWithTitle: [LocalizedStrings MENU_TITLE_ITEM_COPY]
                                                                  action: @selector(copy:)
                                                           keyEquivalent: @"c"]; {
                [editMenu addItem: copyMenuItem];
            }
            
            NSMenuItem *pasteMenuItem = [[NSMenuItem alloc] initWithTitle: [LocalizedStrings MENU_TITLE_ITEM_PASTE]
                                                                   action: @selector(paste:)
                                                            keyEquivalent: @"v"]; {
                [editMenu addItem: pasteMenuItem];
            }
            
            NSMenuItem *selectAllMenuItem = [[NSMenuItem alloc] initWithTitle: [LocalizedStrings MENU_TITLE_ITEM_SELECT_ALL]
                                                                       action: @selector(selectAll:)
                                                                keyEquivalent: @"a"]; {
                [editMenu addItem: selectAllMenuItem];
            }
        }
        
    }
    
    NSMenuItem *windowMenuBarItem = [[NSMenuItem alloc] init]; {
        [menuBar addItem: windowMenuBarItem];
        
        NSMenu *windowMenu = [[NSMenu alloc] initWithTitle: [LocalizedStrings MENU_TITLE_WINDOW]]; {
            [windowMenuBarItem setSubmenu: windowMenu];
            
            closeMenuItem = [[NSMenuItem alloc] initWithTitle: @"Close"
                                                       action: NULL
                                                keyEquivalent: @"w"]; {
                [windowMenu addItem: closeMenuItem];
            }
            
            NSMenuItem *minimizeMenuItem = [[NSMenuItem alloc] initWithTitle: [LocalizedStrings MENU_TITLE_MINIMIZE]
                                                                      action: @selector(miniaturize:)
                                                               keyEquivalent: @"m"]; {
                [windowMenu addItem: minimizeMenuItem];
            }
            
            NSMenuItem *hideMenuItem = [[NSMenuItem alloc] initWithTitle: [LocalizedStrings MENU_TITLE_HIDE]
                                                                  action: @selector(hide:)
                                                           keyEquivalent: @"h"]; {
                [windowMenu addItem: hideMenuItem];
            }
        }
    }
    
    NSMenuItem *supportMeMenuBarItem = [[NSMenuItem alloc] init]; {
        [menuBar addItem: supportMeMenuBarItem];

        NSMenu *supportMeMenu = [[NSMenu alloc] initWithTitle: [LocalizedStrings MENU_TITLE_DONATE_ME]]; {
            [supportMeMenuBarItem setSubmenu: supportMeMenu];
            
            NSMenuItem *openDonationURLMenuItem = [[NSMenuItem alloc] initWithTitle: [LocalizedStrings MENU_TITLE_ITEM_OPEN_DONATION_WEB_PAGE]
                                                                             action: @selector(openDonationsPage)
                                                                      keyEquivalent: @"d"]; {
                [openDonationURLMenuItem setTarget: [HelperFunctions class]];
                
                [supportMeMenu addItem: openDonationURLMenuItem];
            }
        }
    }
    
}

- (void)setupWindows {
    {
        NSSize minWindowSize = CGSizeMake(300, 450);
        NSSize maxWindowSize = CGSizeMake(360, 560);
        
        aboutWindow = [[AboutWindow alloc] initWithNSRect: CGRectMake(0, 0, minWindowSize.width, minWindowSize.height)
                                                    title: [NSString stringWithFormat:@"%@ %@", [LocalizedStrings MENU_TITLE_ITEM_ABOUT], [Constants applicationName]]
                                                  padding: CHILD_CONTENT_SPACING * 2
                                   paddingIsTitleBarAware: YES];
        
        [aboutWindow setMinSize: minWindowSize];
        [aboutWindow setMaxSize: maxWindowSize];
    }
    
    {
        NSSize minWindowSize = CGSizeMake(330, 555);
        NSSize maxWindowSize = CGSizeMake(500, 650);
        
        mainWindow = [[MainWindow alloc] initWithNSRect: CGRectMake(0, 0, minWindowSize.width, minWindowSize.height)
                                                  title: [Constants applicationName]
                                                padding: CHILD_CONTENT_SPACING
                                 paddingIsTitleBarAware: YES
                                            aboutWindow: aboutWindow
                                           quitMenuItem: quitMenuItem
                                          closeMenuItem: closeMenuItem];
        
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
