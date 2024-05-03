//
//  ImagePathVerifyError.swift
//  WinDiskWriter
//
//  Created by Macintosh on 03.05.2024.
//

import Foundation

enum ImagePathVerifyError: Error, LocalizedError {
    case pathIsEmpty
    case notAFile
    case fileNotFound
    case fileNotReadable

    var errorDescription: String? {
        switch self {
        case .pathIsEmpty:
            return "Image path is empty"
        case .notAFile:
            return "Specified path points to a directory, not a file"
        case .fileNotFound:
            return "File not found at specified path"
        case .fileNotReadable:
            return "File at specified path is not readable"
        }
    }
}
