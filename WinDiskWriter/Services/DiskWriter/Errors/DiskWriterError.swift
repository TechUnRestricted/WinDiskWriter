//
//  DiskWriterError.swift
//  WinDiskWriter
//
//  Created by Macintosh on 30.06.2024.
//

import Foundation

enum DiskWriterError: LocalizedError {
    case cannotOpenInputFile
    case cannotOpenOutputFile
    case cannotDetermineFileSize
    case errorReadingFile(String?)
    case errorWritingFile(String?)
    case invalidFileURL
    case fileDoesNotExist

    var errorDescription: String? {
        switch self {
        case .cannotOpenInputFile:
            return "Cannot open input file."
        case .cannotOpenOutputFile:
            return "Cannot open output file."
        case .cannotDetermineFileSize:
            return "Cannot determine file size."
        case .errorReadingFile(let description):
            return "Error reading file: \(unwrappedReason(for: description))"
        case .errorWritingFile(let description):
            return "Error writing file: \(unwrappedReason(for: description))"
        case .invalidFileURL:
            return "Invalid file URL"
        case .fileDoesNotExist:
            return "File does not exist at the specified path"
        }
    }

    private func unwrappedReason(for string: String?) -> String {
        if let string = string {
            return string
        }

        return "Unknown Reason"
    }
}
