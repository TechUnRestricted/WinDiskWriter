//
//  DiskWriterViewModel.swift
//  WinDiskWriter
//
//  Created by Macintosh on 21.04.2024.
//

import Foundation

final class DiskWriterViewModel: NSObject {
    @objc dynamic var imagePath: String = ""
    @objc dynamic var filesystem: Filesystem = .FAT32
    @objc dynamic var patchInstallerRequirements: Bool = false
    @objc dynamic var installLegacyBIOSBootSector: Bool = AppState.hasElevatedRights

    @objc dynamic var isIdle: Bool = true

    @objc dynamic var scanAllWholeDrives: Bool = true

    var appendLogLine: ((LogType, String) -> ())?

    @objc dynamic var disksInfoList: [DiskInfo] = []
    @objc dynamic var chosenDiskInfo: DiskInfo?

    var updateDisksList: (([DiskInfo]) -> ())?
    var selectedDiskInfo: (() -> (DiskInfo?))?

    let isInstallLegacyBIOSBootSectorAvailable: Bool = AppState.hasElevatedRights

    let slideshowStringArray: [String] = [
        "\(AppInfo.developerName) \(Date.adjustedYear)",
        "❤️ Donate Me ❤️"
    ]
    
    private let coordinator: DiskWriterCoordinator
    
    init(coordinator: DiskWriterCoordinator) {
        self.coordinator = coordinator

        super.init()

        setupNotificationCenterObserver()
    }

    deinit {
        removeNotificationCenterObserver()
    }

    private func setupNotificationCenterObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(respondOnQuit),
            name: .menuBarQuitTriggered,
            object: nil
        )
    }

    private func removeNotificationCenterObserver() {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Assigned Actions
extension DiskWriterViewModel {
    func pickImage() {
        coordinator.showFileSelectionSheet { [weak self] selectedPath in
            self?.imagePath = selectedPath
        }
    }

    func updateDevices() {
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
        disksInfoList = filteredDiskInfoList
    }

    func triggerAction() {
        if isIdle {
            startProcess()
        } else {
            stopProcess()
        }
    }

    private func startProcess() {
        do {
            try validateInput()
        } catch {
            let errorString = "Can't start the writing process: (\(error.localizedDescription))"
            appendLogLine?(.error, errorString)

            coordinator.showVerificationFailureWarningAlert(subtitle: error.localizedDescription)
            return
        }

        coordinator.showStartWritingAlert {

        }
    }

    private func stopProcess() {

    }

    func visitDevelopersPage() {
        coordinator.visitDevelopersPage()
    }

    func showRestartWithEscalatedPermissionsAlert() {
        coordinator.showRestartWithEscalatedPermissionsAlert()
    }

    @objc private func respondOnQuit() {

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
        guard !imagePath.isEmpty else {
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
