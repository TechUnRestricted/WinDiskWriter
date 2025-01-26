//
//  ISOMetadata.swift
//  WinDiskWriter
//
//  Created by Macintosh on 15.12.2024.
//

import Foundation

struct ISOMetadata {
    let volumeIdentifier: String
    let systemIdentifier: String
    let volumeSetIdentifier: String
    let publisher: String
    let creationDate: Date
    let capacity: UInt64
}
