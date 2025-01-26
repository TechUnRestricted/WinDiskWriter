//
//  HDIUtilAttachEntity.swift
//  WinDiskWriter
//
//  Created by Macintosh on 22.12.2024.
//

import Foundation

struct HDIUtilAttachEntity: Decodable, Equatable {
    let devEntry: String
    let mountPoint: String
    let volumeKind: String?
    
    enum CodingKeys: String, CodingKey {
        case devEntry = "dev-entry"
        case mountPoint = "mount-point"
        case volumeKind = "volume-kind"
    }
}

extension HDIUtilAttachEntity {
    static func mock() -> Self {
        HDIUtilAttachEntity(
            devEntry: "/dev/disk7",
            mountPoint: "/Volumes/CPBA_X64FRE_EN-US_DV9",
            volumeKind: "udf"
        )
    }
}
