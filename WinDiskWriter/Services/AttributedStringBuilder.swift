//
//  AttributedStringBuilder.swift
//  WinDiskWriter
//
//  Created by Macintosh on 28.04.2024.
//

import Cocoa

class AttributedStringBuilder {
    private let originalMutableAttributedString: NSMutableAttributedString
    private var newAttributes: [NSAttributedString.Key: Any] = [:]

    init(string: String) {
        originalMutableAttributedString = NSMutableAttributedString(string: string)
    }

    init(attributedString: NSAttributedString) {
        originalMutableAttributedString = NSMutableAttributedString(attributedString: attributedString)
    }

    private func updateFont(with traits: NSFontTraitMask? = nil, weight: Int? = nil, size: CGFloat? = nil) {
        let fontManager = NSFontManager.shared
        var font = (newAttributes[.font] as? NSFont) ?? NSFont.systemFont(ofSize: NSFont.systemFontSize)

        if let traits = traits {
            font = fontManager.convert(font, toHaveTrait: traits)
        }

        if let weight = weight {
            font = fontManager.font(
                withFamily: font.familyName ?? "",
                traits: fontManager.traits(of: font),
                weight: weight,
                size: font.pointSize
            ) ?? font
        }

        if let size = size {
            font = NSFont(
                descriptor: font.fontDescriptor,
                size: size
            ) ?? font
        }

        newAttributes[.font] = font
    }

    @discardableResult
    func weight(_ weight: Int) -> AttributedStringBuilder {
        updateFont(weight: weight)
        
        return self
    }

    @discardableResult
    func italic() -> AttributedStringBuilder {
        updateFont(with: .italicFontMask)

        return self
    }

    @discardableResult
    func strikethrough(_ style: NSUnderlineStyle) -> AttributedStringBuilder {
        newAttributes[.strikethroughStyle] = style.rawValue

        return self
    }

    @discardableResult
    func fontSize(_ size: CGFloat) -> AttributedStringBuilder {
        updateFont(size: size)

        return self
    }

    @discardableResult
    func color(_ color: NSColor) -> AttributedStringBuilder {
        newAttributes[.foregroundColor] = color

        return self
    }

    @discardableResult
    func backgroundColor(_ color: NSColor) -> AttributedStringBuilder {
        newAttributes[.backgroundColor] = color

        return self
    }

    @discardableResult
    func underline(_ style: NSUnderlineStyle) -> AttributedStringBuilder {
        newAttributes[.underlineStyle] = style.rawValue

        return self
    }

    @discardableResult
    func baselineOffset(_ offset: CGFloat) -> AttributedStringBuilder {
        newAttributes[.baselineOffset] = offset
        
        return self
    }

    @discardableResult
    func horizontalAlignment(_ alignment: NSTextAlignment) -> AttributedStringBuilder {
        let paragraphStyle = newAttributes[.paragraphStyle] as? NSMutableParagraphStyle ?? NSMutableParagraphStyle()

        paragraphStyle.alignment = alignment
        newAttributes[.paragraphStyle] = paragraphStyle

        return self
    }

    @discardableResult
    func padding(left: CGFloat? = nil, right: CGFloat? = nil, top: CGFloat? = nil, bottom: CGFloat? = nil) -> AttributedStringBuilder {
        let paragraphStyle = (newAttributes[.paragraphStyle] as? NSMutableParagraphStyle) ?? NSMutableParagraphStyle()

        if let left = left {
            paragraphStyle.headIndent = left
            paragraphStyle.firstLineHeadIndent = left
        }

        if let right = right {
            paragraphStyle.tailIndent = -right
        }

        if let top = top {
            paragraphStyle.paragraphSpacingBefore = top
        }

        if let bottom = bottom {
            paragraphStyle.paragraphSpacing = bottom
        }

        newAttributes[.paragraphStyle] = paragraphStyle

        return self
    }

    @discardableResult
    func link(_ url: URL) -> AttributedStringBuilder {
        newAttributes[.link] = url

        return self
    }

    func build() -> NSMutableAttributedString {
        let newAttributedString = originalMutableAttributedString.mutableCopy() as! NSMutableAttributedString

        let range = NSRange(location: 0, length: newAttributedString.length)
        newAttributedString.addAttributes(newAttributes, range: range)

        return newAttributedString
    }
}

extension AttributedStringBuilder {
    static func + (left: AttributedStringBuilder, right: AttributedStringBuilder) -> AttributedStringBuilder {
        let combinedAttributedString = NSMutableAttributedString()
        
        combinedAttributedString.append(
            left.build()
        )

        combinedAttributedString.append(
            right.build()
        )

        return AttributedStringBuilder(attributedString: combinedAttributedString)
    }
}
