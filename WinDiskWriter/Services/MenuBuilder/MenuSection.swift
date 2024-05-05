//
//  MenuSection.swift
//  WinDiskWriter
//
//  Created by Macintosh on 05.05.2024.
//

import Cocoa

class MenuSection: NSObject {
    private let menuItem = NSMenuItem()
    private let menu: NSMenu

    init(title: String) {
        menu = NSMenu(title: title)

        menuItem.submenu = menu
    }

    @discardableResult
    func addItem(title: String, shortcut: String? = nil, action: (() -> Void)? = nil) -> MenuSection {
        let newMenuItem = NSMenuItem(
            title: title,
            action: nil,
            keyEquivalent: shortcut ?? ""
        )

        if let action = action {
            newMenuItem.target = self
            newMenuItem.action = #selector(clickAction(_:))
            newMenuItem.representedObject = action
        }

        menu.addItem(newMenuItem)

        return self
    }

    @discardableResult
    func addSeparator() -> MenuSection {
        let separator = NSMenuItem.separator()

        menu.addItem(separator)

        return self
    }

    @objc private func clickAction(_ sender: NSMenuItem) {
        let clickAction = sender.representedObject as? (() -> Void)
        clickAction?()
    }

    func build() -> NSMenuItem {
        return menuItem
    }
}
