//
//  DiskEraserError.swift
//  WinDiskWriter
//
//  Created by Macintosh on 14.05.2024.
//

import Foundation

enum DiskEraserError: LocalizedError {
    case badBSDName
    case eraseFailedWithMessage(errorMessage: String, terminationStatus: Int32)

    var errorDescription: String? {
        switch self {
        case .badBSDName:
            return "The specified device does not correspond to a valid BSD identifier"
        case .eraseFailedWithMessage(let errorMessage, let status):
            return "Disk erasure failed with termination status \(status): \(errorMessage)"
        }
    }
}
