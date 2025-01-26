//
//  HDIUtilError.swift
//  WinDiskWriter
//
//  Created by Macintosh on 22.12.2024.
//

import Foundation

enum HDIUtilError: LocalizedError {
    case attachFailed(String)
    case detachFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .attachFailed(let message):
            return LocalizedStringResource("Attach failed: \(message)").stringValue
        case .detachFailed(let message):
            return LocalizedStringResource("Detach failed: \(message)").stringValue
        }
    }
}
