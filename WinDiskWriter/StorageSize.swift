//
//  StorageSize.swift
//  WinDiskWriter
//
//  Created by Macintosh on 20.05.2024.
//

import Foundation

struct StorageSize {
    static func bytes(count: UInt64 = 1) -> UInt64 { count * 1 }
    static func kilobytes(count: UInt64 = 1) -> UInt64 { count * 1_024 }
    static func megabytes(count: UInt64 = 1) -> UInt64 { count * 1_024 * 1_024 }
    static func gigabytes(count: UInt64 = 1) -> UInt64 { count * 1_024 * 1_024 * 1_024 }
    static func terabytes(count: UInt64 = 1) -> UInt64 { count * 1_024 * 1_024 * 1_024 * 1_024 }
    static func petabytes(count: UInt64 = 1) -> UInt64 { count * 1_024 * 1_024 * 1_024 * 1_024 * 1_024 }
    static func exabytes(count: UInt64 = 1) -> UInt64 { count * 1_024 * 1_024 * 1_024 * 1_024 * 1_024 * 1_024 }
}
