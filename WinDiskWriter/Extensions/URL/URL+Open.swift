//
//  URL+Open.swift
//  WinDiskWriter
//
//  Created by Macintosh on 13.12.2024.
//

import Foundation
import AppKit

extension URL {
    func open() {
        NSWorkspace.shared.open(self)
    }
}
