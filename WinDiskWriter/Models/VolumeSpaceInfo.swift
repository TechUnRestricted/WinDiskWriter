//
//  VolumeSpaceInfo.swift
//  WinDiskWriter
//
//  Created by Macintosh on 27.01.2025.
//

struct VolumeSpaceInfo {
    let totalBytes: Int64
    let usedBytes: Int64
    let freeBytes: Int64
    
    var description: String {
        let bytesFormatter = ByteCountFormatter()
        bytesFormatter.countStyle = .file
        
        let onDiskFormatter = ByteCountFormatter()
        onDiskFormatter.countStyle = .binary
        
        return LocalizedStringResource("\(bytesFormatter.string(fromByteCount: usedBytes)) (\(onDiskFormatter.string(fromByteCount: usedBytes)) on disk)").stringValue
    }
}
