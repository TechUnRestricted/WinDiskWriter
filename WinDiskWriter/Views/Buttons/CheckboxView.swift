//
//  CheckboxView.swift
//  WinDiskWriter
//
//  Created by Macintosh on 22.04.2024.
//

import AppKit

class CheckboxView: BaseButtonView {
    var isChecked: Bool {
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

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        setButtonType(.switch)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
