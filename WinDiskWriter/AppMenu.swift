//
//  AppMenu.swift
//  WinDiskWriter
//
//  Created by Macintosh on 05.05.2024.
//

import Cocoa

class AppMenu {
    static let menuBuilder: MenuBuilder = {
        let menuBuilder = MenuBuilder()

        let busyStateBinding = StateBinding(
            object: AppService.self,
            keyPath: #keyPath(AppService.isIdle),
            negateBoolean: false
        )

        menuBuilder.addSection(title: "")
            .addItem(
                title: "About \(AppInfo.appName)"
            )
            .addSeparator()
            .addItem(
                title: "Quit \(AppInfo.appName)",
                shortcut: "q",
                action: {
                    NotificationCenter.default.post(name: .menuBarQuitTriggered, object: nil)
                }
            )

        menuBuilder.addSection(title: "Edit")
            .addItem(
                title: "Cut",
                shortcut: "x",
                action: {
                    NSApp.sendAction(#selector(NSText.cut(_:)), to: nil, from: nil)
                }
            )
            .addItem(
                title: "Copy",
                shortcut: "c",
                action: {
                    NSApp.sendAction(#selector(NSText.copy(_:)), to: nil, from: nil)
                }
            )
            .addItem(
                title: "Paste",
                shortcut: "v",
                action: {
                    NSApp.sendAction(#selector(NSText.paste(_:)), to: nil, from: nil)
                }
            )
            .addItem(
                title: "Select All",
                shortcut: "a",
                action: {
                    NSApp.sendAction(#selector(NSText.selectAll(_:)), to: nil, from: nil)
                }
            )

        menuBuilder.addSection(title: "Window")
            .addItem(
                title: "Close",
                shortcut: "w",
                action: { NSApp.mainWindow?.performClose(nil) }
            )
            .addItem(
                title: "Minimize",
                shortcut: "m",
                action: { NSApp.mainWindow?.miniaturize(nil) }
            )
            .addItem(
                title: "Hide",
                shortcut: "h",
                action: {
                    NSApp.hide(nil)
                }
            )

        menuBuilder.addSection(title: "Debug")
            .addItem(
                title: "Scan All Whole Disks",
                stateBinding: busyStateBinding,
                action: {
                    NotificationCenter.default.post(name: .scanAllWholeDisksTriggered, object: nil)
                }
            )
            .addSeparator()
            .addItem(
                title: "Reset All Settings",
                stateBinding: busyStateBinding,
                action: { }
            )

        menuBuilder.addSection(title: "❤️ Donate Me ❤️")
            .addItem(
                title: "Open Donation Web Page",
                shortcut: "d",
                action: {
                    URL(string: GlobalConstants.developerGitHubLink)?.open()
                }
            )

        return menuBuilder
    }()
}
