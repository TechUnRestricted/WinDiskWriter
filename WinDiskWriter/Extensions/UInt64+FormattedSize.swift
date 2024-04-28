//
//  UInt64+FormattedSize.swift
//  WinDiskWriter
//
//  Created by Macintosh on 28.04.2024.
//

import Foundation

extension UInt64 {
    var formattedSize: String {
        let units = ["B", "KB", "MB", "GB", "TB", "PB", "EB"]
        var doubleBytes = Double(self)

        var unitPosition = 0

        while doubleBytes >= 1000 && unitPosition < units.count - 1 {
            doubleBytes /= 1000
            unitPosition += 1
        }

        return String(format: "%.2f %@", doubleBytes, units[unitPosition])
    }
}
