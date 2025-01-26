//
//  String+Stripped.swift
//  WinDiskWriter
//
//  Created by Macintosh on 14.12.2024.
//

import Foundation

extension String {
    func stripped() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
