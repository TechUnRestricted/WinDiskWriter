//
//  TextInputView.swift
//  WinDiskWriter
//
//  Created by Macintosh on 22.04.2024.
//

import AppKit

class TextInputView: NSTextField {
    var textDidChangeEvent: ((String) -> Void)?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        isBordered = true

        lineBreakMode = .byTruncatingMiddle

        isBezeled = true
        bezelStyle = .roundedBezel

        focusRingType = .none
    }

    override func textDidChange(_ notification: Notification) {
        super.textDidChange(notification)

        textDidChangeEvent?(stringValue)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
