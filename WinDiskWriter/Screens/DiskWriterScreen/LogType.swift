//
//  LogType.swift
//  WinDiskWriter
//
//  Created by Macintosh on 08.05.2024.
//

import Foundation

enum LogType {
    case info
    case warning
    case error

    var stringRepresentation: String {
        switch self {
        case .info:
            return "Info"
        case .warning:
            return "Warning"
        case .error:
            return "Error"
        }
    }
}
