//
//  FileManager+ApplicationStorage.swift
//  WinDiskWriter
//
//  Created by Macintosh on 20.05.2024.
//

import Foundation

extension FileManager {
    static var applicationStorage: URL {
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)

        return URL(fileURLWithPath: paths.first ?? NSTemporaryDirectory())
    }
}
