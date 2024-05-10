//
//  CheckboxView.swift
//  WinDiskWriter
//
//  Created by Macintosh on 22.04.2024.
//

import AppKit

extension NSBindingName {
    static let isChecked = NSBindingName(rawValue: #keyPath(CheckboxView.isChecked))
}

class CheckboxView: BaseButtonView {
    @objc dynamic var isChecked: Bool {
        get {
            return state == .on
        } set {
            if newValue {
                state = .on
            } else {
                state = .off
            }
        }
    }

    private static let initBindings: () = {
        CheckboxView.exposeBinding(.isChecked)
    }()

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        Self.initBindings

        setButtonType(.switch)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
