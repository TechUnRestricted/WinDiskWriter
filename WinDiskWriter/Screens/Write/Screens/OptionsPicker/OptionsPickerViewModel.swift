//
//  OptionsPickerViewModel.swift
//  WinDiskWriter
//
//  Created by Macintosh on 25.12.2024.
//

import SwiftUI

class OptionsPickerViewModel: ObservableObject {
    let imageInfo: PickedImageInfo
    
    @Published private var _selectedFilesystem: Filesystem = .FAT32
    var selectedFilesystem: Filesystem {
        get { _selectedFilesystem }
        set {
            if newValue == .exFAT {
                isInstallLegacyBootSectorEnabled = false
            }
            
            _selectedFilesystem = newValue
        }
    }
    
    @Published var selectedDisk: DiskInfo?
    
    @Published private var _isInstallLegacyBootSectorEnabled: Bool = AppHelper.hasElevatedPermissions()
    var isInstallLegacyBootSectorEnabled: Bool {
        get { _isInstallLegacyBootSectorEnabled }
        set {
            if newValue && selectedFilesystem == .exFAT {
                return
            }
            
            if newValue && !AppHelper.hasElevatedPermissions() {
                return
            }
            
            _isInstallLegacyBootSectorEnabled = newValue
        }
    }
    
    @Published var isPatchWindowsInstallerEnabled: Bool = false
        
    @Published var isDisplayingEraseWarning: Bool = false
    
    @Published var errorState: ErrorState?
    
    func verifyConfiguration() {
        guard selectedDisk != nil else {
            errorState = ErrorState(
                title: LocalizedStringResource("No Disk Selected").stringValue,
                description: LocalizedStringResource("Please select a target disk to write the image").stringValue
            )
            
            return
        }
        
        isDisplayingEraseWarning = true
    }
    
    init(imageInfo: PickedImageInfo) {
        self.imageInfo = imageInfo
    }
}
