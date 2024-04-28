//
//  Collection+Safe.swift
//  WinDiskWriter
//
//  Created by Macintosh on 21.04.2024.
//

import Foundation

extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
