//
//  FileManager+FileSize.swift
//  WinDiskWriter
//
//  Created by Macintosh on 30.06.2024.
//

import Foundation

extension FileManager {
    func fileSize(at path: String) -> UInt64? {
        return (try? attributesOfItem(atPath: path)[.size] as? UInt64) ?? nil
    }
}
