//
//  LocalizedStringResource+StringValue.swift
//  WinDiskWriter
//
//  Created by Macintosh on 14.12.2024.
//

import Foundation

extension LocalizedStringResource {
    var stringValue: String {
        String(localized: self)
    }
}
