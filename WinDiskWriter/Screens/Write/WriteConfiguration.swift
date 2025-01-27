//
//  WriteConfiguration.swift
//  WinDiskWriter
//
//  Created by Macintosh on 27.01.2025.
//

struct WriteConfiguration: Equatable {
    let imageInfo: PickedImageInfo
    let selectedDisk: DiskInfo
    
    let filesystem: Filesystem
    let isInstallLegacyBootSectorEnabled: Bool
    let isPatchWindowsInstallerEnabled: Bool
    
    init?(optionsPickerViewModel: OptionsPickerViewModel) {
        self.imageInfo = optionsPickerViewModel.imageInfo
        
        guard let selectedDisk = optionsPickerViewModel.selectedDisk else {
            return nil
        }
        
        self.selectedDisk = selectedDisk
        self.filesystem = optionsPickerViewModel.selectedFilesystem
        self.isInstallLegacyBootSectorEnabled = optionsPickerViewModel.isInstallLegacyBootSectorEnabled
        self.isPatchWindowsInstallerEnabled = optionsPickerViewModel.isPatchWindowsInstallerEnabled
    }
}
