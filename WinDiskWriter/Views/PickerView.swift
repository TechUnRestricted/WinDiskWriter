//
//  PickerView.swift
//  WinDiskWriter
//
//  Created by Macintosh on 22.04.2024.
//

import AppKit

class PickerView: NSPopUpButton {
    override init(frame buttonFrame: NSRect, pullsDown flag: Bool) {
        super.init(frame: buttonFrame, pullsDown: flag)

        bezelStyle = .texturedRounded
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
