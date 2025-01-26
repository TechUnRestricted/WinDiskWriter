//
//  OptionsPickerViewModel.swift
//  WinDiskWriter
//
//  Created by Macintosh on 25.12.2024.
//

import SwiftUI

class OptionsPickerViewModel: ObservableObject {
    let imageInfo: PickedImageInfo
    
    @Published var selectedFilesystem: Filesystem = .FAT32
    @Published var selectedDisk: DiskInfo?
    
    @Published private var _isInstallLegacyBootSectorEnabled: Bool = AppHelper.hasElevatedPermissions()
    var isInstallLegacyBootSectorEnabled: Bool {
        get { _isInstallLegacyBootSectorEnabled }
        set {
            if newValue && !AppHelper.hasElevatedPermissions() {
                return
            }
            
            _isInstallLegacyBootSectorEnabled = newValue
        }
    }
    
    @Published var isPatchWindowsInstallerEnabled: Bool = false
    
    init(imageInfo: PickedImageInfo) {
        self.imageInfo = imageInfo
    }
}
