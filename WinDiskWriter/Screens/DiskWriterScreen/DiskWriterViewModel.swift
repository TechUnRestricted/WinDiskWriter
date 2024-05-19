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
            try verifyImagePath()
            try verifySelectedDevice()
            try verifyInputForCollision()
        } catch {
            let errorString = "Can't start the writing process: (\(error.localizedDescription))"
            appendLogLine?(.error, errorString)
            
            coordinator.showFailureWarningAlert(
                title: "Verification Error",
                subtitle: error.localizedDescription
            )
            
            return
        }
        
        AppService.shared.isIdle = false
        
        // MARK: Image Preparation
        do {
            try mountImage()
        } catch {
            let errorString = "Can't mount the Image: \(error.localizedDescription)"
            appendLogLine?(.error, errorString)
            
            coordinator.showFailureWarningAlert(
                title: "Image Mount Error",
                subtitle: error.localizedDescription
            )
            
            AppService.shared.isIdle = true
            return
        }
        
        // MARK: Disk Space Validation
        do {
            try verifyDiskCapacity(for: .rawDisk)
        } catch {
            let errorString = "Can't verify the Image: \(error.localizedDescription)"
            appendLogLine?(.error, errorString)

            coordinator.showFailureWarningAlert(
                title: "Image Verification Error",
                subtitle: error.localizedDescription
            )

            AppService.shared.isIdle = true
            return
        }

        // MARK: Attempt to erase the disk
        do {
            try eraseDisk()
        } catch {
            let errorString = "Can't erase the Destination Device: \(error.localizedDescription)"
            appendLogLine?(.error, errorString)

            coordinator.showFailureWarningAlert(
                title: "Disk Erase Error",
                subtitle: error.localizedDescription
            )

            AppService.shared.isIdle = true
            return
        }

        // MARK: Volume Space Validation
        do {
            try verifyDiskCapacity(for: .formattedVolume)
        } catch {
            let errorString = "Volume space validation failed: \(error.localizedDescription)"
            appendLogLine?(.error, errorString)

            coordinator.showFailureWarningAlert(
                title: "Volume Space Validation Error",
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


// MARK: - Input Verification
extension DiskWriterViewModel {
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
        
        // TODO: Fix this logic for APFS containers
        if imageFileMountPointBSDName == selectedDiskBSDName {
            throw ConfigurationValidationError.imagePathCollision
        }
    }

    private enum CapacityCheckType {
        case rawDisk
        case formattedVolume
    }

    private func verifyDiskCapacity(for checkType: CapacityCheckType) throws {
        guard let imageMountSystemEntity = imageMountSystemEntity else {
            throw ConfigurationValidationError.imageMountSystemEntityUnavailable
        }

        let imageMountDiskInfo = try DiskInspector.diskInfo(bsdName: imageMountSystemEntity.BSDMountPoint)

        let diskSize: UInt64 = try {
            switch checkType {
            case .rawDisk:
                guard let size = selectedDiskInfo?()?.media.size else {
                    throw ConfigurationValidationError.deviceInfoUnavailable
                }

                return size
            case .formattedVolume:
                guard let volumeURL = erasedDiskVolumeURL else {
                    throw ConfigurationValidationError.volumeInfoUnavailable
                }

                do {
                    let attrs = try FileManager.default.attributesOfFileSystem(forPath: volumeURL.path)

                    guard let volumeSize = attrs[.systemFreeSize] as? UInt64 else {
                        throw ConfigurationValidationError.volumeInfoUnavailable
                    }

                    return volumeSize
                } catch {
                    throw ConfigurationValidationError.volumeInfoUnavailable
                }
            }
        }()

        guard let imageMountSize = imageMountDiskInfo.media.size else {
            throw ConfigurationValidationError.imageInfoUnavailable
        }

        guard diskSize >= imageMountSize else {
            throw ConfigurationValidationError.insufficientDestinationCapacity(imageSize: imageMountSize, destinationCapacity: diskSize)
        }
    }
}
