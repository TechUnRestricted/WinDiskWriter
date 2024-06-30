//
//  StorageSize.swift
//  WinDiskWriter
//
//  Created by Macintosh on 20.05.2024.
//

import Foundation

struct StorageSize {
    static func bytes(count: Int64) -> Int64 { count * 1 }
    static func kilobytes(count: Int64) -> Int64 { count * 1_024 }
    static func megabytes(count: Int64) -> Int64 { count * 1_024 * 1_024 }
    static func gigabytes(count: Int64) -> Int64 { count * 1_024 * 1_024 * 1_024 }
    static func terabytes(count: Int64) -> Int64 { count * 1_024 * 1_024 * 1_024 * 1_024 }
    static func petabytes(count: Int64) -> Int64 { count * 1_024 * 1_024 * 1_024 * 1_024 * 1_024 }
    static func exabytes(count: Int64) -> Int64 { count * 1_024 * 1_024 * 1_024 * 1_024 * 1_024 * 1_024 }
}
