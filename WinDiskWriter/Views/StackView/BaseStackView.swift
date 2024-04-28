//
//  BaseStackView.swift
//  WinDiskWriter
//
//  Created by Macintosh on 22.04.2024.
//

import AppKit

class BaseStackView: NSStackView {
    func appendView(
        _ view: NSView,
        customSpacing: CGFloat?,
        allowsWidthExpansion: Bool,
        allowsHeightExpansion: Bool,
        resistsHorizontalCompression: Bool,
        resistsVerticalCompression: Bool
    ) {
        if let customSpacing = customSpacing, let lastSubview = subviews.last {
            setCustomSpacing(customSpacing, after: lastSubview)
        }

        if allowsWidthExpansion {
            view.setContentHuggingPriority(.fittingSizeCompression, for: .horizontal)
        }

        if allowsHeightExpansion {
            view.setContentHuggingPriority(.fittingSizeCompression, for: .vertical)
        }

        if resistsVerticalCompression {
            view.setContentCompressionResistancePriority(.fittingSizeCompression, for: .vertical)
        }

        if resistsHorizontalCompression {
            view.setContentCompressionResistancePriority(.fittingSizeCompression, for: .horizontal)
        }
    }
}
