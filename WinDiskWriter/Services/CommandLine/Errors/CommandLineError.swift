//
//  CommandLineError.swift
//  WinDiskWriter
//
//  Created by Macintosh on 14.05.2024.
//

import Foundation

enum CommandLineError: LocalizedError {
    case objectiveCException(errorString: String?)

    var errorDescription: String? {
        switch self {
        case .objectiveCException(let errorString):
            return errorString
        }
    }
}
