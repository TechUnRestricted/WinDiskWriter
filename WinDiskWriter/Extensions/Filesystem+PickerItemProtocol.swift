//
//  Filesystem+PickerItemProtocol.swift
//  WinDiskWriter
//
//  Created by Macintosh on 27.01.2025.
//

import SwiftUI

extension Filesystem: PickerItemProtocol {
    var text: String? {
        return name
    }
    
    var image: Image? {
        switch self {
        case .FAT32:
            return Image(systemName: "externaldrive")
        case .exFAT:
            return Image(systemName: "externaldrive")
        }
    }
}
