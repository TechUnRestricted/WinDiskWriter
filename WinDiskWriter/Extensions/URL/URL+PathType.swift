//
//  URL+PathType.swift
//  WinDiskWriter
//
//  Created by Macintosh on 26.05.2024.
//

import Foundation

enum PathType {
    case directory
    case file
    case symbolicLink
    case unknown
}

extension URL {
    var pathType: PathType {
        var isDir: ObjCBool = false
        let fileManager = FileManager.default

        if fileManager.fileExists(atPath: self.path, isDirectory: &isDir) {
            if isDir.boolValue {
                return .directory
            } else if fileManager.isReadableFile(atPath: self.path) {
                return .file
            }
        } else if (try? self.resourceValues(forKeys: [.isSymbolicLinkKey]).isSymbolicLink) == true {
            return .symbolicLink
        }

        return .unknown
    }
}
