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
    
    private func applyFontTraits(_ traits: NSFontTraitMask, weight: Int? = nil) {
        let fontManager = NSFontManager.shared
        var font: NSFont
        
        if let currentFont = attributes[.font] as? NSFont {
            font = currentFont
        } else {
            font = NSFont.systemFont(ofSize: NSFont.systemFontSize)
        }
        
        if let weight = weight {
            font = fontManager.font(withFamily: font.familyName ?? "",
                                    traits: fontManager.traits(of: font),
                                    weight: weight,
                                    size: font.pointSize) ?? font
        }
        
        font = fontManager.convert(font, toHaveTrait: traits)
        
        attributes[.font] = font
    }
    
    func weight(_ weight: Int) -> AttributedStringBuilder {
        applyFontTraits([], weight: weight)
        
        return self
    }
    
    func italic() -> AttributedStringBuilder {
        applyFontTraits(.italicFontMask)
        
        return self
    }
    
    func strikethrough(_ style: NSUnderlineStyle) -> AttributedStringBuilder {
        attributes[.strikethroughStyle] = style.rawValue
        
        return self
    }
    
    func fontSize(_ size: CGFloat) -> AttributedStringBuilder {
        guard let font = attributes[.font] as? NSFont else {
            return self
        }
        
        guard let fontFamily = font.familyName else {
            return self
        }
        
        let newFont = NSFontManager.shared.font(
            withFamily: fontFamily,
            traits: NSFontManager.shared.traits(of: font),
            weight: NSFontManager.shared.weight(of: font),
            size: size
        )
        
        attributes[.font] = newFont ?? font
        
        return self
    }
    
    func color(_ color: NSColor) -> AttributedStringBuilder {
        attributes[.foregroundColor] = color
        
        return self
    }
    
    func backgroundColor(_ color: NSColor) -> AttributedStringBuilder {
        attributes[.backgroundColor] = color
        
        return self
    }
    
    func underline(_ style: NSUnderlineStyle) -> AttributedStringBuilder {
        attributes[.underlineStyle] = style.rawValue
        
        return self
    }
    
    func paragraphStyle(_ style: NSMutableParagraphStyle) -> AttributedStringBuilder {
        attributes[.paragraphStyle] = style
        
        return self
    }
    
    func link(_ url: URL) -> AttributedStringBuilder {
        attributes[.link] = url
        
        return self
    }
    
    func build() -> NSAttributedString {
        return NSAttributedString(string: string, attributes: attributes)
    }
}
