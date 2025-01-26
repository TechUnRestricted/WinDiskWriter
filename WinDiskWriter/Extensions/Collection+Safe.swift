//
//  Collection+Safe.swift
//  WinDiskWriter
//
//  Created by Macintosh on 14.12.2024.
//

import Foundation

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
