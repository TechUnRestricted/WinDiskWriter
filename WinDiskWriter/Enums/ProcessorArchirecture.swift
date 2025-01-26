//
//  ProcessorArchirecture.swift
//  WinDiskWriter
//
//  Created by Macintosh on 21.12.2024.
//

enum ProcessorArchirecture: String {
    case x86_32
    case x86_64
    
    var windowsStyledDescription: String {
        switch self {
        case .x86_32:
            return "x86"
        case .x86_64:
            return "x64"
        }
    }
}
