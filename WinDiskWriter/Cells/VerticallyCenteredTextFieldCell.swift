//
//  VerticallyCenteredTextFieldCell.swift
//  WinDiskWriter
//
//  Created by Macintosh on 26.04.2024.
//

import Cocoa

final class VerticallyCenteredTextFieldCell: NSTextFieldCell {
    private enum Constants {
        static let fontScalingFactor: CGFloat = 0.9
        static let horizontalPadding: CGFloat = 3
    }

    static let usedFont = NSFont.systemFont(ofSize: NSFont.systemFontSize * Constants.fontScalingFactor)

    // Make font a read-only property
    override var font: NSFont? {
        set { }
        get {
            Self.usedFont
        }
    }

    override init(textCell: String) {
        super.init(textCell: textCell)

        font = Self.usedFont
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func titleRect(forBounds theRect: NSRect) -> NSRect {
        let titleSize = attributedStringValue.size()

        // Calculate vertical centering.
        let verticalPadding = (theRect.height - titleSize.height) / 2.0
        let newY = theRect.origin.y + verticalPadding

        // Calculate horizontal shift.
        let newX = theRect.origin.x + Constants.horizontalPadding

        // Adjust the width for the horizontal padding to keep text within bounds.
        let adjustedWidth = theRect.width - (Constants.horizontalPadding * 2)

        return NSRect(x: newX, y: newY, width: adjustedWidth, height: titleSize.height)
    }

    override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
        var titleRect = self.titleRect(forBounds: cellFrame)
        titleRect.size.width += Constants.horizontalPadding * 2

        self.attributedStringValue.draw(in: titleRect)
    }
}
