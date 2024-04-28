//
//  AppService.swift
//  WinDiskWriter
//
//  Created by Macintosh on 27.04.2024.
//

import Foundation

class AppService {
    static var hasElevatedRights: Bool {
        return geteuid() == 0;
    }
}
