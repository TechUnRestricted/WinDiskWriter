//
//  DiskInfo.swift
//  WinDiskWriter
//
//  Created by Macintosh on 28.04.2024.
//

import Foundation

struct DiskInfo {
    var BSDName: String
    var mediaSize: Int
    var appearanceTime: TimeInterval

    var BSDUnit: Int?
    var mediaBSDMajor: Int?
    var mediaBSDMinor: Int?
    var blockSize: Int?

    var isWholeDrive: Bool?
    var isInternal: Bool?
    var isMountable: Bool?
    var isRemovable: Bool?
    var isWritable: Bool?
    var isEncrypted: Bool?
    var isNetworkVolume: Bool?
    var isEjectable: Bool?
    var isDeviceUnit: Bool?

    var devicePath: String?
    var deviceModel: String?
    var mediaKind: String?
    var volumeKind: String?
    var volumeName: String?
    var volumePath: String?
    var mediaPath: String?
    var mediaName: String?
    var mediaContent: String?
    var busPath: String?
    var deviceProtocol: String?
    var deviceRevision: String?
    var busName: String?
    var deviceVendor: String?

    func appearanceNSDate() -> Date {
        return Date(timeIntervalSinceReferenceDate: appearanceTime)
    }

    func BSDFullPath() -> String {
        return "/dev/" + BSDName
    }
}

