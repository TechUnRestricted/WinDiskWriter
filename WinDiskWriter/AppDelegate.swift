//
//  AppDelegate.swift
//  WinDiskWriter
//
//  Created by Macintosh on 21.04.2024.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var coordinator: MainCoordinator?
    let menuBuilder = MenuBuilder()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSApp.activate(ignoringOtherApps: true)

        NSApp.mainMenu = AppMenu.menuBuilder.build()

        coordinator = MainCoordinator()
        coordinator?.start()
    }

    func applicationWillTerminate(_ aNotification: Notification) {

    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

