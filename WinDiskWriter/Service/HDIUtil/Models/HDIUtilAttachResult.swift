//
//  HDIUtilAttachResult.swift
//  WinDiskWriter
//
//  Created by Macintosh on 22.12.2024.
//

import Foundation

struct HDIUtilAttachResult: Decodable {
    let entities: [HDIUtilAttachEntity]

    enum CodingKeys: String, CodingKey {
        case entities = "system-entities"
    }
}
