//
//  AppHelper.swift
//  WinDiskWriter
//
//  Created by Macintosh on 14.12.2024.
//

private enum UserDefaultsKeys: String {
    case launchedBefore
}

import Foundation

enum AppHelper {
    
    /// Checks if the app has been run before and updates the state.
    /// - Returns: `true` if this is the first run, `false` otherwise.
    static func launchedBefore() -> Bool {
        let userDefaults = UserDefaults.standard
        let key = UserDefaultsKeys.launchedBefore.rawValue
        
        let isLaunchedBefore = userDefaults.bool(forKey: key)
        if !isLaunchedBefore {
            userDefaults.set(true, forKey: key)
            return false
        }
        
        return true
    }
    
    static func hasElevatedPermissions() -> Bool {
        return geteuid() == 0
    }
    
    static func openGitHubPage() {
        GlobalConstants.Links.sourceCodePage.open()
    }
}
