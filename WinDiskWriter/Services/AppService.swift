//
//  AppService.swift
//  WinDiskWriter
//
//  Created by Macintosh on 08.05.2024.
//

import Foundation
import AppKit

class AppService: NSObject {
    private override init() { }

    static let shared = AppService()

    @objc dynamic var isIdle: Bool = true

    static var hasElevatedRights: Bool {
        return geteuid() == 0;
    }

    static func terminate(_ sender: Any? = nil) {
        NSApplication.shared.terminate(sender)
    }

    static func openDevelopersGitHubPage() {
        URL(string: GlobalConstants.developersGitHubLink)?.open()
    }

    static func hasEnoughStorage(for requiredSpace: UInt64) {
        let fileURL = URL(fileURLWithPath: NSHomeDirectory())

        let values = try? fileURL.resourceValues(forKeys: [.volumeAvailableCapacityKey])
        guard let availableSpace = values?.volumeAvailableCapacity, availableSpace < requiredSpace else {
            return
        }
    }
}
