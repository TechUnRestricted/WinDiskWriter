//
//  CommandLineError.swift
//  WinDiskWriter
//
//  Created by Macintosh on 22.12.2024.
//

import Foundation

/// An error type for handling CommandLine execution errors.
enum CommandLineError: LocalizedError {
    case commandFailed(exitCode: Int32, errorMessage: String)
    case invalidCommand
    case invalidExecutablePath

    var errorDescription: String? {
        switch self {
        case .commandFailed(let exitCode, let errorMessage):
            return LocalizedStringResource("\(errorMessage) (Exit Code: \(exitCode))").stringValue
        case .invalidCommand:
            return LocalizedStringResource("Invalid command provided.").stringValue
        case .invalidExecutablePath:
            return LocalizedStringResource("Invalid executable path provided.").stringValue
        }
    }
}
