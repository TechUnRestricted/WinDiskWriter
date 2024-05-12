//
//  AppInfo.swift
//  WinDiskWriter
//
//  Created by Macintosh on 04.05.2024.
//

import Foundation

enum AppInfo {
    static var developerName: String = "TechUnRestricted"
    static var appName: String = "WinDiskWriter"

    static var appVersion: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
    }
}
