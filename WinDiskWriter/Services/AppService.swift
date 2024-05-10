//
//  AppService.swift
//  WinDiskWriter
//
//  Created by Macintosh on 08.05.2024.
//

import Foundation
import AppKit

class AppService {
    private init() { }

    static var hasElevatedRights: Bool {
        return geteuid() == 0;
    }

    static func terminate(_ sender: Any? = nil) {
        NSApplication.shared.terminate(sender)
    }
}
