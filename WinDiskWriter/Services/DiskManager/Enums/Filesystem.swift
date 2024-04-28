//
//  Filesystem.swift
//  WinDiskWriter
//
//  Created by Macintosh on 27.04.2024.
//

import Foundation

enum Filesystem: Int, Hashable {
    case FAT32 = 0
    case exFAT = 1
}

extension Filesystem {
    var parameterRepresentation: String {
        switch self {
        case .FAT32:
            return "FAT32"
        case .exFAT:
            return "EXFAT"
        }
    }
}
