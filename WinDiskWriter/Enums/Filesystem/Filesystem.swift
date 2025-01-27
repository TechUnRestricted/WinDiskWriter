//
//  Filesystem.swift
//  WinDiskWriter
//
//  Created by Macintosh on 27.01.2025.
//

import SwiftUI

enum Filesystem: CaseIterable {
    case FAT32
    case exFAT
    
    var id: String {
        return name
    }
    
    var name: String {
        switch self {
        case .FAT32:
            return "FAT32"
        case .exFAT:
            return "ExFAT"
        }
    }
    
    var maxNameLength: Int {
        switch self {
        case .FAT32:
            return 11 // 8.3 format length
        case .exFAT:
            return 255
        }
    }
    
    var forbiddenCharacters: CharacterSet? {
        switch self {
        case .FAT32:
            return CharacterSet(charactersIn: "*?<>|\":/\\[]+=;,")
        case .exFAT:
            return nil // ExFAT is more permissive
        }
    }
    
    func validateName(_ name: String) throws {
        guard !name.isEmpty else {
            throw FilesystemError.emptyName
        }
        
        guard name.count <= maxNameLength else {
            throw FilesystemError.nameTooLong(filesystem: self, maxLength: maxNameLength)
        }
        
        if let forbidden = forbiddenCharacters,
           name.rangeOfCharacter(from: forbidden) != nil {
            throw FilesystemError.forbiddenCharacters(filesystem: self)
        }
        
        if self == .FAT32 && name.trimmingCharacters(in: .whitespaces).count != name.count {
            throw FilesystemError.invalidSpacing(filesystem: self)
        }
    }
}
