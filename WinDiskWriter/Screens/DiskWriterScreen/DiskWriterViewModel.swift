//
//  DiskWriterViewModel.swift
//  WinDiskWriter
//
//  Created by Macintosh on 21.04.2024.
//

import Foundation

final class DiskWriterViewModel {
    var imagePath: (() -> (String))?
    var didSelectImagePath: ((String) -> (Void))?
    
    var filesystem: (() -> (Filesystem))?
    
    var patchInstallerRequirements: (() -> (Bool))?
    var installLegacyBIOSBootSector: (() -> (Bool))?
    
    var isInWritingProcess: (() -> (Bool))?
    var setInWritingProcess: ((Bool) -> ())?
    
    var updateDisksList: (([DiskInfo]) -> ())?
    var selectedDiskInfo: (() -> (DiskInfo?))?

    var appendLogLine: ((String) -> ())?
    
    var isInstallLegacyBIOSBootSectorAvailable: Bool {
        get {
            guard AppService.hasElevatedRights else {
                coordinator.showRestartWithEscalatedPermissionsAlert()
                return false
            }
            
            return true
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
}

extension DiskWriterViewModel {
    func pickImage() {
        coordinator.showFileSelectionSheet { [weak self] selectedPath in
            self?.didSelectImagePath?(selectedPath)
        }
    }

    func updateDevices() {
        let unfilteredDiskInfoList = DiskInspector.getDisksInfoList()

        var filteredDiskInfoList: [DiskInfo] = []

        for diskInfo in unfilteredDiskInfoList {
            filteredDiskInfoList.append(diskInfo)
        }

        updateDisksList?(filteredDiskInfoList)
    }

    func startStopProcess() {
        guard inputIsValid() else {
            return
        }


    }

    func visitDevelopersPage() {
        coordinator.visitDevelopersPage()
    }
}

extension DiskWriterViewModel {
    private func inputIsValid() -> Bool {
        do {
            try verifyImagePath()
            try verifySelectedDevice()
        } catch {
            coordinator.showVerificationFailureWarning(subtitle: error.localizedDescription)
            return false
        }

        return true
    }

    private func verifyImagePath() throws {
        guard let imagePath = imagePath?() else {
            throw ImagePathVerifyError.pathIsEmpty
        }

        if imagePath.isEmpty {
            throw ImagePathVerifyError.pathIsEmpty
        }

        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: imagePath, isDirectory: &isDirectory) else {
            throw ImagePathVerifyError.fileNotFound
        }

        if isDirectory.boolValue {
            throw ImagePathVerifyError.notAFile
        }

        guard FileManager.default.isReadableFile(atPath: imagePath) else {
            throw ImagePathVerifyError.fileNotReadable
        }
    }

    private func verifySelectedDevice() throws {
        guard let selectedDiskInfo = selectedDiskInfo?() else {
            return
        }

        print(selectedDiskInfo.appearanceTime)

        return

        let selectedDeviceAppearanceTimestamp = selectedDiskInfo.appearanceNSDate().timeIntervalSince1970

        try? DiskInspector.diskInfo(bsdName: selectedDiskInfo.BSDName).appearanceTime
        
    }
}
