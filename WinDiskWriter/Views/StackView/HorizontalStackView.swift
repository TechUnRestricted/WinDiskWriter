//
//  HorizontalStackView.swift
//  WinDiskWriter
//
//  Created by Macintosh on 21.04.2024.
//

import AppKit

class HorizontalStackView: BaseStackView {
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        orientation = .horizontal
        alignment = .width
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func appendView(
        _ view: NSView,
        customSpacing: CGFloat? = nil,
        allowsWidthExpansion: Bool = true,
        allowsHeightExpansion: Bool = true,
        resistsHorizontalCompression: Bool = false,
        resistsVerticalCompression: Bool = false
    ) {
        super.appendView(
            view,
            customSpacing: customSpacing,
            allowsWidthExpansion: allowsWidthExpansion,
            allowsHeightExpansion: allowsHeightExpansion,
            resistsHorizontalCompression: resistsHorizontalCompression,
            resistsVerticalCompression: resistsVerticalCompression
        )

        addView(view, in: .trailing)
    }
}
