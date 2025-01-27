//
//  FileManager+VolumeSpaceInfo.swift
//  WinDiskWriter
//
//  Created by Macintosh on 27.01.2025.
//

import Foundation

extension FileManager {
    func volumeSpaceInfo(at url: URL) throws -> VolumeSpaceInfo {
        let resourceValues = try url.resourceValues(forKeys: [
            .volumeTotalCapacityKey,
            .volumeAvailableCapacityKey
        ])
        
        guard let totalBytes = resourceValues.volumeTotalCapacity,
              let freeBytes = resourceValues.volumeAvailableCapacity else {
            throw CocoaError(.fileReadUnknown)
        }
        
        return VolumeSpaceInfo(
            totalBytes: Int64(totalBytes),
            usedBytes: Int64(totalBytes - freeBytes),
            freeBytes: Int64(freeBytes)
        )
    }
}
