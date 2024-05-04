//
//  NSView+SetEnabledStateForAllControls.swift
//  WinDiskWriter
//
//  Created by Macintosh on 03.05.2024.
//

import AppKit

extension NSView {
    func setEnabledStateForAllControls(_ enabled: Bool) {
        for subview in subviews {
            (subview as? NSControl)?.isEnabled = enabled

            // Recursive call for nested subviews
            subview.setEnabledStateForAllControls(enabled)
        }
    }
}
