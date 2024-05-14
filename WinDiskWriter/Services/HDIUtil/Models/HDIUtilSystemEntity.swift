//
//  HDIUtilSystemEntity.swift
//  WinDiskWriter
//
//  Created by Macintosh on 28.04.2024.
//

import Foundation

struct HDIUtilSystemEntity: Decodable {
    let BSDMountPoint: String
    let mountPoint: String
    let potentiallyMountable: Bool
    let volumeKind: String

    enum CodingKeys: String, CodingKey {
        case BSDMountPoint = "dev-entry"
        case mountPoint = "mount-point"
        case potentiallyMountable = "potentially-mountable"
        case volumeKind = "volume-kind"
    }
}
