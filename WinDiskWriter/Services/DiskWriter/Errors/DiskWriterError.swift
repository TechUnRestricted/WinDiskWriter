//
//  DiskWriterError.swift
//  WinDiskWriter
//
//  Created by Macintosh on 26.05.2024.
//

import Foundation

enum DiskWriterError: LocalizedError {
    case processAlreadyRunning
    case contentsIterationFailed
    
    var errorDescription: String? {
        switch self {
        case .processAlreadyRunning:
            return "Another process is already running"
        case .contentsIterationFailed:
            return "Failed to iterate the contents of a directory"
        }
    }
}
