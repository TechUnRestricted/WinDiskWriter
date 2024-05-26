//
//  DiskWriterError.swift
//  WinDiskWriter
//
//  Created by Macintosh on 26.05.2024.
//

import Foundation

enum DiskWriterError: LocalizedError {
    case processAlreadyRunning

    var errorDescription: String? {
        switch self {
        case .processAlreadyRunning:
            return "Another process is already running"
        }
    }
}
