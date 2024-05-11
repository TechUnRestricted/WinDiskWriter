//
//  MenuSection.swift
//  WinDiskWriter
//
//  Created by Macintosh on 05.05.2024.
//

import Cocoa

struct StateBinding {
    let object: AnyObject
    let keyPath: String
    let negateBoolean: Bool
}

class MenuSection {
    private let menuItem = NSMenuItem()
    private let menu: NSMenu

    init(title: String) {
        menu = NSMenu(title: title)
        menu.autoenablesItems = false

        menuItem.submenu = menu
    }

    @discardableResult
    func addItem(
        title: String,
        shortcut: String? = nil,
        stateBinding: StateBinding? = nil,
        action: (() -> Void)? = nil
    ) -> MenuSection {
        let newMenuItem = NSMenuItem(
            title: title,
            action: nil,
            keyEquivalent: shortcut ?? ""
        )

        if let stateBinding = stateBinding {
            var bindingOptions: [NSBindingOption: Any] = [
                .validatesImmediately: true
            ]

            if stateBinding.negateBoolean {
                bindingOptions[.valueTransformerName] = NSValueTransformerName.negateBooleanTransformerName
            }

            newMenuItem.bind(
                .enabled,
                to: stateBinding.object,
                withKeyPath: stateBinding.keyPath,
                options: bindingOptions
            )
        }

        if let action = action {
            newMenuItem.target = self
            newMenuItem.action = #selector(clickAction(_:))
            newMenuItem.representedObject = action
        } else {
            newMenuItem.isEnabled = false
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
