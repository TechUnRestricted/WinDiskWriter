//
//  Image+AppImage.swift
//  WinDiskWriter
//
//  Created by Macintosh on 13.12.2024.
//

import SwiftUI

extension Image {
    static var appIcon: Image {
        guard let appIcon = NSApplication.shared.applicationIconImage else {
            return Image(systemName: "app.fill")
        }
        return Image(nsImage: appIcon)
    }
}
