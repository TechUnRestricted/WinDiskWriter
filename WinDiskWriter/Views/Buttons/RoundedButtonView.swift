//
//  RoundedButtonView.swift
//  WinDiskWriter
//
//  Created by Macintosh on 22.04.2024.
//

import AppKit

class RoundedButtonView: BaseButtonView {
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        bezelStyle = .rounded
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
