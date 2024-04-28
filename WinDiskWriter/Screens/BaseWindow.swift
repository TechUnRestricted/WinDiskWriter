//
//  BaseWindow.swift
//  WinDiskWriter
//
//  Created by Macintosh on 21.04.2024.
//

import AppKit

class BaseWindow: NSWindow {
    var titleBarHeight: CGFloat = 0.0

    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
        titleBarHeight = max(frame.height - contentRect.height, 0)

        isMovableByWindowBackground = true
        titlebarAppearsTransparent = true
        styleMask.insert(.fullSizeContentView)
    }
}
