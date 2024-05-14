//
//  DiskInspectorError.swift
//  WinDiskWriter
//
//  Created by Macintosh on 14.05.2024.
//

import Foundation

enum DiskInspectorError: LocalizedError {
    case sessionCreationFailed
    case diskReferenceCreationFailed
    case diskCopyDescriptionFailed
    case unableToRetrieveServices
    case invalidFAT32Name(reason: String)

    var errorDescription: String? {
        switch self {
        case .sessionCreationFailed:
            return "Can't create a DiskArbitration session"
        case .diskReferenceCreationFailed:
            return "Can't create a DiskArbitration disk session for the specified initializer"
        case .diskCopyDescriptionFailed:
            return "Can't extract the descriptive information from the disk"
        case .unableToRetrieveServices:
            return "Can't retrieve IO Services with specified options"
        case .invalidFAT32Name(let reason):
            return "Invalid FAT32 name: \(reason)"
        }
    }
}
