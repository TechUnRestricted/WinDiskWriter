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
    
    NSMenuItem *scanAllWholeDisksMenuItem;
}

- (void)setupMenuItems {
    NSMenu *menuBar = [[NSMenu alloc]init];
    [NSApp setMainMenu: menuBar];
    
    NSMenuItem *mainMenuBarItem = [[NSMenuItem alloc] init]; {
        [menuBar addItem:mainMenuBarItem];
        
        NSMenu *mainItemsMenu = [[NSMenu alloc] init]; {
            [mainMenuBarItem setSubmenu:mainItemsMenu];
            
            NSMenuItem *aboutMenuItem = [[NSMenuItem alloc] initWithTitle: [LocalizedStrings menuTitleItemAbout]
                                                                   action: @selector(showAboutWindow)
                                                            keyEquivalent: @""]; {
                [mainItemsMenu addItem: aboutMenuItem];
            }
            
            [mainItemsMenu addItem: NSMenuItem.separatorItem];
            
            quitMenuItem = [[NSMenuItem alloc] initWithTitle: [NSString stringWithFormat: @"%@ %@", [LocalizedStrings menuTitleItemQuit], [Constants applicationName]]
                                                      action: NULL
                                               keyEquivalent: @"q"]; {
                [mainItemsMenu addItem:quitMenuItem];
            }
            
        }
    }
    
    NSMenuItem *editMenuBarItem = [[NSMenuItem alloc] init]; {
        [menuBar addItem:editMenuBarItem];
        
        NSMenu *editMenu = [[NSMenu alloc] initWithTitle: [LocalizedStrings menuTitleEdit]]; {
            [editMenuBarItem setSubmenu: editMenu];
            
            NSMenuItem *cutMenuItem = [[NSMenuItem alloc] initWithTitle: [LocalizedStrings menuTitleItemCut]
                                                                 action: @selector(cut:)
                                                          keyEquivalent: @"x"]; {
                [editMenu addItem: cutMenuItem];
            }
            
            NSMenuItem *copyMenuItem = [[NSMenuItem alloc] initWithTitle: [LocalizedStrings menuTitleItemCopy]
                                                                  action: @selector(copy:)
                                                           keyEquivalent: @"c"]; {
                [editMenu addItem: copyMenuItem];
            }
            
            NSMenuItem *pasteMenuItem = [[NSMenuItem alloc] initWithTitle: [LocalizedStrings menuTitleItemPaste]
                                                                   action: @selector(paste:)
                                                            keyEquivalent: @"v"]; {
                [editMenu addItem: pasteMenuItem];
            }
            
            NSMenuItem *selectAllMenuItem = [[NSMenuItem alloc] initWithTitle: [LocalizedStrings menuTitleItemSelectAll]
                                                                       action: @selector(selectAll:)
                                                                keyEquivalent: @"a"]; {
                [editMenu addItem: selectAllMenuItem];
            }
        }
        
    }
    
    NSMenuItem *windowMenuBarItem = [[NSMenuItem alloc] init]; {
        [menuBar addItem: windowMenuBarItem];
        
        NSMenu *windowMenu = [[NSMenu alloc] initWithTitle: [LocalizedStrings menuTitleWindow]]; {
            [windowMenuBarItem setSubmenu: windowMenu];
            
            closeMenuItem = [[NSMenuItem alloc] initWithTitle: [LocalizedStrings menuTitleItemClose]
                                                       action: NULL
                                                keyEquivalent: @"w"]; {
                [windowMenu addItem: closeMenuItem];
            }
            
            NSMenuItem *minimizeMenuItem = [[NSMenuItem alloc] initWithTitle: [LocalizedStrings menuTitleMinimize]
                                                                      action: @selector(miniaturize:)
                                                               keyEquivalent: @"m"]; {
                [windowMenu addItem: minimizeMenuItem];
            }
            
            NSMenuItem *hideMenuItem = [[NSMenuItem alloc] initWithTitle: [LocalizedStrings menuTitleHide]
                                                                  action: @selector(hide:)
                                                           keyEquivalent: @"h"]; {
                [windowMenu addItem: hideMenuItem];
            }
        }
    }
    
    NSMenuItem *debugMenuBarItem = [[NSMenuItem alloc] init]; {
        [menuBar addItem: debugMenuBarItem];
        
        NSMenu *debugMenu = [[NSMenu alloc] initWithTitle: [LocalizedStrings menuTitleItemDebug]]; {
            [debugMenuBarItem setSubmenu: debugMenu];
            
            scanAllWholeDisksMenuItem = [[NSMenuItem alloc] init]; {
                [scanAllWholeDisksMenuItem setTitle: [LocalizedStrings menuTitleScanAllWholeDisks]];
                                                
                [debugMenu addItem: scanAllWholeDisksMenuItem];
            }
            
            [debugMenu addItem: NSMenuItem.separatorItem];
            
            NSMenuItem *resetAppSettingsMenuItem = [[NSMenuItem alloc] init]; {
                [resetAppSettingsMenuItem setTitle: @"Reset All Settings"];
                [resetAppSettingsMenuItem setTarget: self];
                [resetAppSettingsMenuItem setAction: @selector(showResetSettingsAlert)];
                
                [debugMenu addItem: resetAppSettingsMenuItem];
            }

        }
    }
    
    NSMenuItem *supportMeMenuBarItem = [[NSMenuItem alloc] init]; {
        [menuBar addItem: supportMeMenuBarItem];
        
        NSMenu *supportMeMenu = [[NSMenu alloc] initWithTitle: [LocalizedStrings menuTitleDonateMe]]; {
            [supportMeMenuBarItem setSubmenu: supportMeMenu];
            
            NSMenuItem *openDonationURLMenuItem = [[NSMenuItem alloc] initWithTitle: [LocalizedStrings menuTitleItemOpenDonationWebPage]
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
                                                    title: [NSString stringWithFormat:@"%@ %@", [LocalizedStrings menuTitleItemAbout], [Constants applicationName]]
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
                                          closeMenuItem: closeMenuItem
                              scanAllWholeDisksMenuItem: scanAllWholeDisksMenuItem];
        
        [mainWindow setMinSize: minWindowSize];
        [mainWindow setMaxSize: maxWindowSize];
    }
}

- (void)showAboutWindow {
    [aboutWindow showWindow];
}

- (void)showResetSettingsAlert {
    NSMutableString *informativeText = [NSMutableString stringWithFormat: @"This operation will clear all Application Data for the '%@' user.", NSUserName()];
    [informativeText appendString: @"\n"];

    
    BOOL isRoot = [HelperFunctions hasElevatedRights];
    
    if (isRoot) {
        [informativeText appendString: @"After, to complete the settings removal, relaunch the application with a non-root user and perform this action again."];
    } else {
        [informativeText appendString: @"After, to complete the settings removal, click on the 'Patch Installer Requirements' button (this will relaunch the application as root) and perform this action again."];
    }
    
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText: @"Reset All Settings"];
    [alert setInformativeText: informativeText];
    [alert addButtonWithTitle: @"No"];
    [alert addButtonWithTitle: @"Yes"];
    
    [alert beginSheetModalForWindow: mainWindow
                      modalDelegate: self
                     didEndSelector: @selector(alertResetSettingsPromptDidEnd:returnCode:contextInfo:)
                        contextInfo: NULL];
}

- (void)alertResetSettingsPromptDidEnd: (NSAlert *)alert
                            returnCode: (NSInteger)returnCode
                           contextInfo: (void *)contextInfo {

    if (returnCode != NSAlertSecondButtonReturn) {
        return;
    }
    
    [HelperFunctions resetApplicationSettings];
    [HelperFunctions restartAppWithElevatedPermissions: NO
                                                 error: NULL];

}

- (void)forceDisplayAppInFront {
    [NSApp activateIgnoringOtherApps: YES];
    [mainWindow makeKeyAndOrderFront: NULL];
    [NSApp activateIgnoringOtherApps: NO];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self setupMenuItems];
    [self setupWindows];
    [self forceDisplayAppInFront];

    [HelperFunctions cleanupTempFolders];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    [HelperFunctions cleanupTempFolders];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return NO;
}

@end
