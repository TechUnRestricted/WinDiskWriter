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
    @objc dynamic var installLegacyBIOSBootSector: Bool = AppService.hasElevatedRights
    
    @objc dynamic var disksInfoList: [DiskInfo] = []
    
    var selectedDiskInfo: (() -> (DiskInfo?))?
    
    var appendLogLine: ((LogType, String) -> ())?
    
    let isInstallLegacyBIOSBootSectorAvailable: Bool = AppService.hasElevatedRights
    
    let slideshowStringArray: [String] = [
        "\(AppInfo.developerName) \(Date.adjustedYear)",
        "❤️ Donate Me ❤️"
    ]
    
    private var imageMountSystemEntity: HDIUtilSystemEntity?
    private var erasedDiskVolumeURL: URL?

    private let coordinator: DiskWriterCoordinator
    
    init(coordinator: DiskWriterCoordinator) {
        self.coordinator = coordinator
        
        super.init()
        
        setupNotificationCenterObservers()
    }
    
    deinit {
        removeNotificationCenterObserver()
    }

    private func resetProcessProperties() {
        imageMountSystemEntity = nil
        erasedDiskVolumeURL = nil
    }

    private func setupNotificationCenterObservers() {
        let notificationCenterDictionary: [Notification.Name: Selector] = [
            .menuBarQuitTriggered: #selector(respondOnQuit),
            .scanAllWholeDisksTriggered: #selector(respondOnScanAllWholeDisks)
        ]
        
        for (name, selector) in notificationCenterDictionary {
            NotificationCenter.default.addObserver(
                self,
                selector: selector,
                name: name,
                object: nil
            )
        }
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
    
    func updateDevices(enableFiltering: Bool = true) {
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
            
            if enableFiltering {
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
        
        disksInfoList = filteredDiskInfoList
    }
    
    func visitDevelopersPage() {
        AppService.openDevelopersGitHubPage()
    }
    
    func showRestartWithEscalatedPermissionsAlert() {
        coordinator.showRestartWithEscalatedPermissionsAlert()
    }
    
    func triggerAction() {
        if AppService.shared.isIdle {
            coordinator.showStartWritingAlert { [weak self] in
                self?.startProcess()
            }
        } else {
            coordinator.showStopWritingAlert { [weak self] in
                self?.stopProcess()
            }
        }
    }
    
    private func startProcess() {
        resetProcessProperties()

        // MARK: Pre-Write Checks
        do {
            try DiskValidator.verifyImagePath(imagePath)
            try DiskValidator.verifySelectedDevice(selectedDiskInfo?())
            try DiskValidator.verifyInputForCollision(imagePath, selectedDiskInfo?())
        } catch {
            let errorTypeMessage = "Invalid Input"
            let errorDescription = "\(errorTypeMessage): (\(error.localizedDescription))"

            appendLogLine?(.error, errorDescription)

            coordinator.showFailureWarningAlert(
                title: errorTypeMessage,
                subtitle: error.localizedDescription
            )

            return
        }

        AppService.shared.isIdle = false

        // MARK: Image Preparation
        do {
            try mountImage()
        } catch {
            let errorTypeMessage = "Image Mount Failure"
            let errorDescription = "\(errorTypeMessage): (\(error.localizedDescription))"

            appendLogLine?(.error, errorDescription)

            coordinator.showFailureWarningAlert(
                title: errorTypeMessage,
                subtitle: error.localizedDescription
            )

            AppService.shared.isIdle = true
            return
        }

        // MARK: Disk Space Validation
        do {
            try DiskValidator.verifyRawDiskCapacity(
                selectedDiskInfo: selectedDiskInfo?(),
                imageMountSystemEntity: imageMountSystemEntity
            )
        } catch {
            let errorTypeMessage = "Disk Capacity Verification Failure"
            let errorDescription = "\(errorTypeMessage): (\(error.localizedDescription))"

            appendLogLine?(.error, errorDescription)

            coordinator.showFailureWarningAlert(
                title: errorTypeMessage,
                subtitle: error.localizedDescription
            )

            AppService.shared.isIdle = true
            return
        }

        // MARK: Attempt to erase the disk
        do {
            try eraseDisk()
        } catch {
            let errorTypeMessage = "Disk Erase Failure"
            let errorDescription = "\(errorTypeMessage): (\(error.localizedDescription))"

            appendLogLine?(.error, errorDescription)

            coordinator.showFailureWarningAlert(
                title: errorTypeMessage,
                subtitle: error.localizedDescription
            )

            AppService.shared.isIdle = true
            return
        }

        // MARK: Volume Space Validation
        do {
            try DiskValidator.verifyFormattedVolumeCapacity(
                erasedDiskVolumeURL: erasedDiskVolumeURL,
                imageMountSystemEntity: imageMountSystemEntity
            )
        } catch {
            let errorTypeMessage = "Disk Capacity Verification Failure"
            let errorDescription = "\(errorTypeMessage): (\(error.localizedDescription))"

            appendLogLine?(.error, errorDescription)

            coordinator.showFailureWarningAlert(
                title: errorTypeMessage,
                subtitle: error.localizedDescription
            )

            AppService.shared.isIdle = true
            return
        }
    }

    private func stopProcess() {
        AppService.shared.isIdle = true
    }

    @objc private func respondOnQuit() {
        if AppService.shared.isIdle {
            AppService.terminate(self)
        }

        coordinator.showUnsafeTerminateAlert()
    }

    @objc private func respondOnScanAllWholeDisks() {
        updateDevices(enableFiltering: false)
    }
}

extension DiskWriterViewModel {
    private func mountImage() throws {
        let imageFileURL = URL(fileURLWithPath: imagePath)

        imageMountSystemEntity = try HDIUtil.attachImage(imageURL: imageFileURL)
    }

    private func eraseDisk() throws {
        guard let selectedDiskBSDName = selectedDiskInfo?()?.media.bsdName else {
            throw ConfigurationValidationError.deviceInfoUnavailable
        }

        let generatedVolumeName = DiskEraser.generateFAT32Name(prefix: "WDW_", randomCharLimit: 7)

        try DiskEraser.eraseWholeDisk(
            bsdName: selectedDiskBSDName,
            filesystem: .FAT32,
            partitionScheme: .MBR,
            partitionName: generatedVolumeName
        )
    }
}
