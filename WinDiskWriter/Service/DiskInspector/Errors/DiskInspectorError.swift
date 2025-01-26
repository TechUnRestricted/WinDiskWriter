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
    case unableToRetrieveBSDName
    case invalidFAT32Name(reason: String)

    var errorDescription: String? {
        switch self {
        case .sessionCreationFailed:
            return LocalizedStringResource("Can't create a DiskArbitration session.").stringValue
        case .diskReferenceCreationFailed:
            return LocalizedStringResource("Can't create a DiskArbitration disk session for the specified initializer.").stringValue
        case .diskCopyDescriptionFailed:
            return LocalizedStringResource("Can't extract the descriptive information from the disk.").stringValue
        case .unableToRetrieveServices:
            return LocalizedStringResource("Can't retrieve IO Services with specified options.").stringValue
        case .unableToRetrieveBSDName:
            return LocalizedStringResource("Can't retrieve from the disk.").stringValue
        case .invalidFAT32Name(let reason):
            return LocalizedStringResource("Invalid FAT32 name: \(reason).").stringValue
        }
    }
}
