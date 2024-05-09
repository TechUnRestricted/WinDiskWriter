//
//  AppState.swift
//  WinDiskWriter
//
//  Created by Macintosh on 08.05.2024.
//

import Foundation

class AppState {
    private init() { }

    static var hasElevatedRights: Bool {
        return geteuid() == 0;
    }

    static var isQuitAvailable: Bool = true
}
