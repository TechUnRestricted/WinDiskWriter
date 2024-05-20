//
//  FileManager+RequiredAdditionalSpace.swift
//  WinDiskWriter
//
//  Created by Macintosh on 20.05.2024.
//

import Foundation

extension FileManager {
    static func requiredAdditionalSpace(for url: URL, size: UInt64) throws -> UInt64 {
        let availableSpaceResourceValues = try url.resourceValues(forKeys: [.volumeAvailableCapacityKey])

        guard let availableSpace = availableSpaceResourceValues.volumeAvailableCapacity else {
            let errorDescription = "Failed to retrieve available disk space"
            let errorInfo: [String: Any] = [NSLocalizedDescriptionKey: errorDescription]

            throw NSError(domain: NSPOSIXErrorDomain, code: 0, userInfo: errorInfo)
        }

        return size > UInt64(availableSpace) ? size - UInt64(availableSpace) : 0
    }
}
