//
//  DiskInfo+Hashable.swift
//  WinDiskWriter
//
//  Created by Macintosh on 29.12.2024.
//

extension DiskInfo: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(device.vendor)
        hasher.combine(device.model)
        hasher.combine(media.size)
        hasher.combine(media.bsdName)
        hasher.combine(device.path)
    }
}
