//
//  ScrollableTextView.swift
//  WinDiskWriter
//
//  Created by Macintosh on 12.05.2024.
//

import AppKit

class ScrollableTextView: NSScrollView {
    private enum Constants {
        static let cornderRadius: CGFloat = 10.0
        static let borderWidth: CGFloat = 1.5
        static let borderColor: CGColor = NSColor.textColor.withAlphaComponent(0.25).cgColor
        static let containerInsets: NSSize = NSSize(width: 5, height: 10)
    }

    var string: String {
        get {
            textView.string
        } set {
            textView.string = newValue
        }
    }

    private let textView = NSTextView()

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        hasVerticalScroller = true
        autohidesScrollers = true
        hasHorizontalScroller = false
        drawsBackground = false

        contentView.wantsLayer = true
        contentView.layer?.cornerRadius = Constants.cornderRadius
        contentView.layer?.borderColor = Constants.borderColor
        contentView.layer?.borderWidth = Constants.borderWidth

        textView.textContainerInset = Constants.containerInsets
        textView.autoresizingMask = .width
        textView.isEditable = false
        textView.isSelectable = true
        textView.focusRingType = .none

        self.documentView = textView
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func bind(_ binding: NSBindingName, to observable: Any, withKeyPath keyPath: String, options: [NSBindingOption : Any]? = nil) {
        textView.bind(binding, to: observable, withKeyPath: keyPath, options: options)
    }

    override func unbind(_ binding: NSBindingName) {
        textView.unbind(binding)
    }

    override var exposedBindings: [NSBindingName] {
        get {
            return textView.exposedBindings
        }
    }

    override var allowsVibrancy: Bool {
        return true
    }
}
