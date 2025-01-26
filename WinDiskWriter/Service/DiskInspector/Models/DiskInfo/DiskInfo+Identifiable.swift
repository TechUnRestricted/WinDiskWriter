//
//  DiskInfo+Identifiable.swift
//  WinDiskWriter
//
//  Created by Macintosh on 29.12.2024.
//

extension DiskInfo: Identifiable {
    var id: String {
        let components = [
            device.vendor ?? "",
            device.model ?? "",
            String(media.size ?? 0),
            media.bsdName,
            device.path ?? ""
        ]
        
        let combinedString = components.joined(separator: "_")
        
        return combinedString
    }
}
