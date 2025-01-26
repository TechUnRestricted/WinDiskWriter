//
//  Bundle+AppVersion.swift
//  WinDiskWriter
//
//  Created by Macintosh on 14.12.2024.
//

import Foundation

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
    
    var releaseWithBuildVersionHumanReadableString: String {
        var string: String = ""
        
        if let releaseVersionNumber {
            string.append(releaseVersionNumber)
        }
        
        if let buildVersionNumber {
            string.append(" (\(buildVersionNumber))")
        }
        
        return string.stripped()
    }
}
