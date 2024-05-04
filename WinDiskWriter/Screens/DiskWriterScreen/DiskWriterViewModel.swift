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

// MARK: - Assigned Actions
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
        guard let isInWritingProcess = isInWritingProcess?(),
            !isInWritingProcess else {
            return
        }

        do {
            try validateInput()
        } catch {
            coordinator.showVerificationFailureWarningAlert(subtitle: error.localizedDescription)
        }

        coordinator.showStartWritingAlert {

        }
    }

    func stopProcess() {
        guard let isInWritingProcess = isInWritingProcess?(),
            isInWritingProcess else {
            return
        }

    }

    func visitDevelopersPage() {
        coordinator.visitDevelopersPage()
    }
}

// MARK: - Input Verification
extension DiskWriterViewModel {
    private func validateInput() throws {
        try verifyImagePath()
        try verifySelectedDevice()
        try verifyInputForCollision()
    }

    private func verifyImagePath() throws {
        guard let imagePath = imagePath?(),
              !imagePath.isEmpty else {
            throw ConfigurationValidationError.emptyImagePath
        }

        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: imagePath, isDirectory: &isDirectory) else {
            throw ConfigurationValidationError.fileNotFound
        }

        if isDirectory.boolValue {
            throw ConfigurationValidationError.notAFile
        }

        guard FileManager.default.isReadableFile(atPath: imagePath) else {
            throw ConfigurationValidationError.fileNotReadable
        }
    }

    private func verifySelectedDevice() throws {
        guard let selectedDiskInfo = selectedDiskInfo?() else {
            throw ConfigurationValidationError.noDeviceSelected
        }

        guard let selectedDiskBSDName = selectedDiskInfo.media.bsdName,
              let originalDiskAppearanceTime = selectedDiskInfo.media.appearanceTime else {
                  throw ConfigurationValidationError.deviceInfoUnavailable
        }

        var updatedDiskAppearanceTime: TimeInterval = .nan

        do {
            let updatedDiskInfo = try DiskInspector.diskInfo(bsdName: selectedDiskBSDName)
            updatedDiskAppearanceTime = updatedDiskInfo.media.appearanceTime ?? .nan
        } catch {
            throw ConfigurationValidationError.deviceInfoUnavailable
        }

        if originalDiskAppearanceTime != updatedDiskAppearanceTime {
            throw ConfigurationValidationError.appearanceTimestampDiscrepancy
        }
    }

    private func verifyInputForCollision() throws {
        guard let imagePath = imagePath?() else {
            throw ConfigurationValidationError.emptyImagePath
        }

        guard let selectedDiskBSDName = selectedDiskInfo?()?.media.bsdName else {
            throw ConfigurationValidationError.deviceInfoUnavailable
        }

        guard let imageFileMountPointURL = URL(fileURLWithPath: imagePath).mountPoint else {
            throw ConfigurationValidationError.mountPointUnavailable
        }

        var imageFileMountPointDiskInfo: DiskInfo?
        do {
            imageFileMountPointDiskInfo = try DiskInspector.diskInfo(volumeURL: imageFileMountPointURL)
        } catch {
            throw ConfigurationValidationError.imageDiskInfoUnavailable
        }

        guard let imageFileMountPointBSDName = imageFileMountPointDiskInfo?.media.bsdName else {
            throw ConfigurationValidationError.imageDiskInfoUnavailable
        }

        if imageFileMountPointBSDName == selectedDiskBSDName {
            throw ConfigurationValidationError.imagePathCollision
        }
    }
}
