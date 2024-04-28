//
//  String+Stripped.swift
//  WinDiskWriter
//
//  Created by Macintosh on 28.04.2024.
//

import Foundation

extension String {
    func stripped() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
