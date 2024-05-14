//
//  FileReaderError.swift
//  WinDiskWriter
//
//  Created by Macintosh on 12.05.2024.
//

import Foundation

enum FileReaderError: LocalizedError {
    case fileTooLarge
    case fileNotFound
    case fileNotReadable
    case unspecified(Error)

    var errorDescription: String? {
        switch self {
        case .fileTooLarge:
            return "The file is too large to be processed"
        case .fileNotFound:
            return "The file could not be found at the specified URL"
        case .fileNotReadable:
            return "The file is not readable"
        case .unspecified(let error):
            return error.localizedDescription
        }
    }
}
