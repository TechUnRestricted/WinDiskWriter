//
//  String+HasOneOfThePrefixes.swift
//  WinDiskWriter
//
//  Created by Macintosh on 28.04.2024.
//

import Foundation

extension String {
    func hasOneOfThePrefixes(_ prefixes: [String]) -> Bool {
        for prefix in prefixes {
            if self.hasPrefix(prefix) {
                return true
            }
        }
        return false
    }
}
