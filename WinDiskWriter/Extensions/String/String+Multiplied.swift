//
//  String+Multiplied.swift
//  WinDiskWriter
//
//  Created by Macintosh on 28.12.2024.
//

import Foundation

extension String {
    /// Repeats the string `count` times.
    /// - Parameter count: The number of times to repeat the string.
    /// - Returns: A new string that is the result of repeating the string `count` times, or an empty string if `count` is less than 1.
    func multiplied(by count: Int) -> String {
        guard count > 0 else { return "" }
        return String(repeating: self, count: count)
    }
}
