//
//  Filesystem.swift
//  WinDiskWriter
//
//  Created by Macintosh on 27.01.2025.
//

import SwiftUI

enum Filesystem: PickerItemProtocol, CaseIterable {
    case FAT32
    case exFAT
    
    var id: String {
        switch self {
        case .FAT32:
            return "fat32-fs"
        case .exFAT:
            return "exfat-fs"
        }
    }
    
    var text: String? {
        switch self {
        case .FAT32:
            return "FAT32"
        case .exFAT:
            return "ExFAT"
        }
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
