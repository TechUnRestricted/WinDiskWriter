//
//  URL+Open.swift
//  WinDiskWriter
//
//  Created by Macintosh on 27.04.2024.
//

import Cocoa

extension URL {
    func open() {
        NSWorkspace.shared.open(self)
    }
}
