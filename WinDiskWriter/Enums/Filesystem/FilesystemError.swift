//
//  FilesystemError.swift
//  WinDiskWriter
//
//  Created by Macintosh on 27.01.2025.
//

enum FilesystemError: LocalizedError {
    case emptyName
    case nameTooLong(filesystem: Filesystem, maxLength: Int)
    case forbiddenCharacters(filesystem: Filesystem)
    case invalidSpacing(filesystem: Filesystem)
    
    var errorDescription: String? {
        switch self {
        case .emptyName:
            return LocalizedStringResource("Volume name cannot be empty").stringValue
        case .nameTooLong(let filesystem, let maxLength):
            return LocalizedStringResource(
                "Volume name for \(filesystem.name) cannot exceed \(maxLength) characters"
            ).stringValue
        case .forbiddenCharacters(let filesystem):
            return LocalizedStringResource(
                "Volume name for \(filesystem.name) contains forbidden characters"
            ).stringValue
        case .invalidSpacing(let filesystem):
            return LocalizedStringResource(
                "Volume name for \(filesystem.name) cannot begin or end with spaces"
            ).stringValue
        }
    }
}
