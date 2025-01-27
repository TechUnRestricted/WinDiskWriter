//
//  DiskUtilError.swift
//  WinDiskWriter
//
//  Created by Macintosh on 27.01.2025.
//

import Foundation

enum DiskUtilError: LocalizedError {
    case invalidDevice
    case commandFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .commandFailed(let message):
            return LocalizedStringResource("Disk erase operation failed: \(message)").stringValue
        case .invalidDevice:
            return LocalizedStringResource("Invalid device identifier provided").stringValue
        }
    }
}
