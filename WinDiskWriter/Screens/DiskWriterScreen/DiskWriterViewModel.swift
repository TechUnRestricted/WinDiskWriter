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

    var scanAllWholeDrives: (() -> (Bool))?

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
        guard let scanAllWholeDrives = scanAllWholeDrives?() else {
            return
        }

        let unfilteredDiskInfoList = DiskInspector.getDisksInfoList()

        var filteredDiskInfoList: [DiskInfo] = []

        for diskInfo in unfilteredDiskInfoList {
            guard let isWholeDrive = diskInfo.media.isWhole,
                  let isWritable = diskInfo.media.isWritable else {
                      continue
                  }

            if !isWholeDrive || !isWritable {
                continue
            }

            if !scanAllWholeDrives {
                guard let isNetworkVolume = diskInfo.volume.isNetwork,
                    let isInternal = diskInfo.device.isInternal else {
                        continue
                    }

                if isNetworkVolume || isInternal {
                    continue
                }
            }

            filteredDiskInfoList.append(diskInfo)
        }

        updateDisksList?(filteredDiskInfoList)
    }

    func startProcess() {
        guard inputIsValid() else {
            return
        }

        coordinator.showStartWritingAlert {

        }
    }

    func stopProcess() {
        
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
            coordinator.showVerificationFailureWarningAlert(subtitle: error.localizedDescription)
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
        guard let selectedDiskInfo = selectedDiskInfo?(),
              let selectedDiskBSDName = selectedDiskInfo.media.bsdName,
              let originalDiskAppearanceTime = selectedDiskInfo.media.appearanceTime else {
            throw SelectedDeviceVerifyError.unableToRetrieveUpdatedDeviceInfo
        }

        var updatedDiskAppearanceTime: TimeInterval = .nan

        do {
            let updatedDiskInfo = try DiskInspector.diskInfo(bsdName: selectedDiskBSDName)
            updatedDiskAppearanceTime = updatedDiskInfo.media.appearanceTime ?? .nan
        } catch {
            throw SelectedDeviceVerifyError.unableToRetrieveUpdatedDeviceInfo
        }

        if originalDiskAppearanceTime != updatedDiskAppearanceTime {
            throw SelectedDeviceVerifyError.appearanceTimestampDiscrepancy
        }
    }
}
