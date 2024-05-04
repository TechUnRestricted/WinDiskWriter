//
//  FileManager+SetAllPermissions.swift
//  WinDiskWriter
//
//  Created by Macintosh on 28.04.2024.
//

import Foundation

extension FileManager {
    func setAllPermissions(forPath path: String) throws {
        let fileSystemRepresentation = (path as NSString).fileSystemRepresentation
        let fullPermissions = S_IRWXU | S_IRWXG | S_IRWXO

        guard chmod(fileSystemRepresentation, fullPermissions) != -1 else {
            throw NSError(
                domain: NSPOSIXErrorDomain,
                code: Int(errno),
                userInfo: [NSLocalizedDescriptionKey: String(cString: strerror(errno))]
            )
        }
    }
}
