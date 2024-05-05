//
//  MenuBuilder.swift
//  WinDiskWriter
//
//  Created by Macintosh on 05.05.2024.
//

import Cocoa

class MenuBuilder {
    private var menuSections: [MenuSection] = []

    @discardableResult
    func addSection(title: String) -> MenuSection {
        let menuSection = MenuSection(title: title)
        menuSections.append(menuSection)

        return menuSection
    }

    func build() -> NSMenu {
        let menuBar = NSMenu()

        for menuSection in menuSections {
            menuBar.addItem(menuSection.build())
        }

        return menuBar
    }
}
