//
//  DraggableImageView.swift
//  WinDiskWriter
//
//  Created by Macintosh on 11.05.2024.
//

import AppKit

class DraggableImageView: NSImageView {
    override var mouseDownCanMoveWindow: Bool {
        return true
    }
}
