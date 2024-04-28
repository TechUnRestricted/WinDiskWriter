//
//  DiskInfo.swift
//  WinDiskWriter
//
//  Created by Macintosh on 28.04.2024.
//

import Foundation

struct DiskInfo {
    var isWholeDrive: Bool
    var isInternal: Bool
    var isMountable: Bool
    var isRemovable: Bool
    var isDeviceUnit: Bool
    var isWritable: Bool
    var isEncrypted: Bool
    var isNetworkVolume: Bool
    var isEjectable: Bool

    var BSDUnit: Int?
    var mediaSize: Int?
    var mediaBSDMajor: Int?
    var mediaBSDMinor: Int?
    var blockSize: Int?
    var appearanceTime: TimeInterval?

    var devicePath: String?
    var deviceModel: String?
    var BSDName: String?
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
    // var volumeUUID: String?

    func appearanceNSDate() -> Date? {
        guard let time = appearanceTime else {
            return nil
        }

        return Date(timeIntervalSinceReferenceDate: time)
    }

    func BSDFullPath() -> String? {
        guard let BSDName = BSDName else {
            return nil
        }

        return "/dev/\(BSDName)"
    }
}

