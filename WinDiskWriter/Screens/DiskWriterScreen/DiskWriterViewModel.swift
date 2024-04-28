//
//  DiskWriterViewModel.swift
//  WinDiskWriter
//
//  Created by Macintosh on 21.04.2024.
//

import Foundation

final class DiskWriterViewModel {
    var imagePath: (() -> (String))?
    var didSelectImagePath: ((String) -> Void)?
    
    var filesystem: (() -> (Filesystem))?
    
    var patchInstallerRequirements: (() -> (Bool))?
    var installLegacyBIOSBootSector: (() -> (Bool))?
    
    var isInWritingProcess: (() -> (Bool))?
    var setInWritingProcess: ((Bool) -> ())?
    
    var updateDisksList: (([DiskInfo]) -> ())?
    
    var appendLogLine: ((String) -> ())?
    
    var isInstallLegacyBIOSBootSectorAvailable: Bool {
        get {
            return false
        }
    }
    
    let slideshowStringArray: [String] = [
        "\(GlobalConstants.developerName) \(Date.adjustedYear)",
        "❤️ Donate Me ❤️"
    ]
    
    private let coordinator: DiskWriterCoordinator
    
    init(coordinator: DiskWriterCoordinator) {
        self.coordinator = coordinator
    }
    
    func pickImage() {
        coordinator.showFileSelectionSheet { [weak self] selectedPath in
            self?.didSelectImagePath?(selectedPath)
        }
    }
    
    func updateDevices() {
        let unfilteredDiskInfoList = DiskInspector.getDisksInfoList()
        
        var filteredDiskInfoList: [DiskInfo] = []
        
        for diskInfo in unfilteredDiskInfoList {
            if !diskInfo.isWholeDrive || !diskInfo.isWritable || !diskInfo.isDeviceUnit || diskInfo.isNetworkVolume || diskInfo.isInternal {
                continue
            }
            
            filteredDiskInfoList.append(diskInfo)
        }
        
        updateDisksList?(filteredDiskInfoList)
    }
    
    func startStopProcess() {
      
    }
    
    func visitDevelopersPage() {
        URL(string: GlobalConstants.developerGitHubLink)?.open()
    }
}
