//
//  AppInfo.swift
//  WinDiskWriter
//
//  Created by Macintosh on 04.05.2024.
//

import Foundation

enum AppInfo {
    static let developerName: String = "TechUnRestricted"
    static let appName: String = "WinDiskWriter"
    static let appDescription: String = "Windows Bootable Disk Creator for macOS"

    static var appVersion: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
    }
}
