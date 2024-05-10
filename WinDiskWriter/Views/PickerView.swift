//
//  PickerView.swift
//  WinDiskWriter
//
//  Created by Macintosh on 22.04.2024.
//

import AppKit

extension NSBindingName {
    static let menuItems = NSBindingName(rawValue: #keyPath(PickerView.menuItems))
}

class PickerView: NSPopUpButton {
    @objc dynamic fileprivate var menuItems: [NSMenuItem] {
        get {
            return menu?.items ?? []
        } set {
            menu?.items = newValue
        }
    }

    private static let initBindings: () = {
        PickerView.exposeBinding(.menuItems)
    }()

    override init(frame buttonFrame: NSRect, pullsDown flag: Bool) {
        super.init(frame: buttonFrame, pullsDown: flag)

        Self.initBindings

        bezelStyle = .texturedRounded
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
