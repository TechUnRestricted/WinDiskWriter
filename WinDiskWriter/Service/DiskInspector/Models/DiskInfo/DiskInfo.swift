//
//  DiskInfo.swift
//  WinDiskWriter
//
//  Created by Macintosh on 28.04.2024.
//

import Foundation

class DiskInfo: Encodable {
    struct Volume: Encodable {
        var kind: String?
        var isMountable: Bool?
        var name: String?
        var isNetwork: Bool?
        var path: URL?
        var type: String?
        var uuid: UUID?
    }
    
    struct Media: Encodable {
        var appearanceTime: TimeInterval?
        var blockSize: Int?
        var bsdMajor: Int?
        var bsdMinor: Int?
        var bsdName: String
        var bsdUnit: Int?
        var content: String?
        var isEjectable: Bool?
        var kind: String?
        var isLeaf: Bool?
        var name: String?
        var path: String?
        var isRemovable: Bool?
        var size: UInt64?
        var type: String?
        var uuid: UUID?
        var isWhole: Bool?
        var isWritable: Bool?
        var isEncrypted: Bool?
        var encryptionDetail: Int?
    }
    
    struct Device: Encodable {
        var guid: Data?
        var isInternal: Bool?
        var model: String?
        var path: String?
        var `protocol`: String?
        var revision: String?
        var unit: Int?
        var vendor: String?
        var isTDMLocked: Bool?
    }
    
    struct Bus: Encodable {
        var name: String?
        var path: String?
    }
    
    var volume: Volume
    var media: Media
    var device: Device
    var bus: Bus
    
    init(volume: Volume, media: Media, device: Device, bus: Bus) {
        self.volume = volume
        self.media = media
        self.device = device
        self.bus = bus
    }
}
