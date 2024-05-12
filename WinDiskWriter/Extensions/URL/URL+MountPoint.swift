//
//  URL+MountPoint.swift
//  WinDiskWriter
//
//  Created by Macintosh on 04.05.2024.
//

import Foundation

extension URL {
    var mountPoint: URL? {
        let keys: Set<URLResourceKey> = [.volumeURLKey]
        guard let values = try? self.resourceValues(forKeys: keys) else {
            return nil
        }

        return values.volume
    }
}
