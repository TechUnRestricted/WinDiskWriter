//
//  ISOMetadataParserError.swift
//  WinDiskWriter
//
//  Created by Macintosh on 15.12.2024.
//

import Foundation

enum ISOMetadataParserError: LocalizedError {
    case fileNotFound
    case invalidISOImage
    case readError
    case metadataNotFound
    case unsupportedFormat

    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return LocalizedStringResource("The specified ISO file was not found.").stringValue
        case .invalidISOImage:
            return LocalizedStringResource("The file is not a valid ISO image or is corrupted.").stringValue
        case .readError:
            return LocalizedStringResource("An error occurred while attempting to read the ISO file.").stringValue
        case .metadataNotFound:
            return LocalizedStringResource("Required metadata could not be found in the ISO file.").stringValue
        case .unsupportedFormat:
            return LocalizedStringResource("The ISO file format is not supported.").stringValue
        }
    }
}
