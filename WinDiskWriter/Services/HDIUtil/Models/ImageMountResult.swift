//
//  HDIUtilImageMountResult.swift
//  WinDiskWriter
//
//  Created by Macintosh on 28.04.2024.
//

import Foundation

struct HDIUtilImageMountResult: Decodable {
    let systemEntities: [HDIUtilSystemEntity]?

    enum CodingKeys: String, CodingKey {
        case systemEntities = "system-entities"
    }
}
