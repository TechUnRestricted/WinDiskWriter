//
//  Int+FormattedSize.swift
//  WinDiskWriter
//
//  Created by Macintosh on 29.12.2024.
//

import Foundation

// MARK: - Size Formatting Protocol
protocol SizeFormattable {
    var formattedSize: String { get }
    func formattedSize(style: ByteCountFormatter.CountStyle, allowedUnits: ByteCountFormatter.Units) -> String
}

// MARK: - Size Formatting Implementation
extension SizeFormattable where Self: BinaryInteger {
    var formattedSize: String {
        formattedSize(style: .file, allowedUnits: .useAll)
    }
    
    func formattedSize(style: ByteCountFormatter.CountStyle = .file,
                      allowedUnits: ByteCountFormatter.Units = .useAll) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = style
        formatter.allowedUnits = allowedUnits
        formatter.includesUnit = true
        formatter.isAdaptive = true
        formatter.zeroPadsFractionDigits = false
        
        return formatter.string(fromByteCount: Int64(self))
    }
}

extension Int: SizeFormattable {}
extension Int64: SizeFormattable {}
extension Int32: SizeFormattable {}
extension Int16: SizeFormattable {}
extension Int8: SizeFormattable {}
extension UInt: SizeFormattable {}
extension UInt64: SizeFormattable {}
extension UInt32: SizeFormattable {}
extension UInt16: SizeFormattable {}
extension UInt8: SizeFormattable {}
