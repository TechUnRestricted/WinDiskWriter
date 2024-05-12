//
//  NSImage+ApplicationIcon.swift
//  WinDiskWriter
//
//  Created by Macintosh on 11.05.2024.
//

import AppKit

extension NSImage {
    static var applicationIcon: NSImage? {
        return NSWorkspace.shared.icon(forFile: Bundle.main.bundlePath)
    }
}
