//
//  DiskInfo+Equatable.swift
//  WinDiskWriter
//
//  Created by Macintosh on 29.12.2024.
//

extension DiskInfo: Equatable {
    static func == (lhs: DiskInfo, rhs: DiskInfo) -> Bool {
        // Compare device identifiers first
        let deviceMatch = lhs.device.vendor == rhs.device.vendor &&
                         lhs.device.model == rhs.device.model &&
                         lhs.device.path == rhs.device.path
        
        // If device matches, then compare media properties
        let mediaMatch = lhs.media.bsdName == rhs.media.bsdName &&
                        lhs.media.size == rhs.media.size
        
        return deviceMatch && mediaMatch
    }
}
