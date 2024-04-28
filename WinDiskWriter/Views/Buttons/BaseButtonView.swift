//
//  BaseButtonView.swift
//  WinDiskWriter
//
//  Created by Macintosh on 22.04.2024.
//

import AppKit

class BaseButtonView: NSButton {
    var clickAction: (() -> Void)?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        target = self
        action = #selector(buttonPressed)
    }

    @objc func buttonPressed() {
        clickAction?()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
