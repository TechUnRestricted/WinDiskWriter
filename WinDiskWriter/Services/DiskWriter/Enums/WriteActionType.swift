//
//  WriteActionType.swift
//  WinDiskWriter
//
//  Created by Macintosh on 26.05.2024.
//

import Foundation

enum WriteActionType {
    case createFolder(url: URL)
    case copyFile(source: URL, destination: URL)
    case removeFile(url: URL)
    case patchInstallerRequirements
    case installLegacyBootSector
}
