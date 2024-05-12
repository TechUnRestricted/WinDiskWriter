//
//  AttributedStringBuilder.swift
//  WinDiskWriter
//
//  Created by Macintosh on 28.04.2024.
//

import Cocoa

class AttributedStringBuilder {
    private var attributes: [NSAttributedString.Key: Any] = [:]
    private var string: String

    init(string: String) {
        self.string = string
    }

    private func updateFont(with traits: NSFontTraitMask? = nil, weight: Int? = nil, size: CGFloat? = nil) {
        let fontManager = NSFontManager.shared
        var font = attributes[.font] as? NSFont ?? NSFont.systemFont(ofSize: NSFont.systemFontSize)

        if let traits = traits {
            font = fontManager.convert(font, toHaveTrait: traits)
        }

        if let weight = weight, let newFont = fontManager.font(withFamily: font.familyName ?? "", traits: fontManager.traits(of: font), weight: weight, size: font.pointSize) {
            font = newFont
        }

        if let size = size, let newFont = NSFont(descriptor: font.fontDescriptor, size: size) {
            font = newFont
        }

        attributes[.font] = font
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
        attributes[.strikethroughStyle] = style.rawValue

        return self
    }

    @discardableResult
    func fontSize(_ size: CGFloat) -> AttributedStringBuilder {
        updateFont(size: size)

        return self
    }

    @discardableResult
    func color(_ color: NSColor) -> AttributedStringBuilder {
        attributes[.foregroundColor] = color

        return self
    }

    @discardableResult
    func backgroundColor(_ color: NSColor) -> AttributedStringBuilder {
        attributes[.backgroundColor] = color

        return self
    }

    @discardableResult
    func underline(_ style: NSUnderlineStyle) -> AttributedStringBuilder {
        attributes[.underlineStyle] = style.rawValue

        return self
    }

    @discardableResult
    func horizontalAlignment(_ alignment: NSTextAlignment) -> AttributedStringBuilder {
        let paragraphStyle = attributes[.paragraphStyle] as? NSMutableParagraphStyle ?? NSMutableParagraphStyle()

        paragraphStyle.alignment = alignment
        attributes[.paragraphStyle] = paragraphStyle

        return self
    }

    @discardableResult
    func link(_ url: URL) -> AttributedStringBuilder {
        attributes[.link] = url

        return self
    }

    func build() -> NSAttributedString {
        return NSAttributedString(string: string, attributes: attributes)
    }
}
