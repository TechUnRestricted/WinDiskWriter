//
//  DiskValidator.swift
//  WinDiskWriter
//
//  Created by Macintosh on 19.05.2024.
//

import Foundation

struct DiskValidator {
    static func verifyImagePath(_ imagePath: String) throws {
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
    
    static func verifySelectedDevice(_ selectedDiskInfo: DiskInfo?) throws {
        guard let selectedDiskInfo = selectedDiskInfo else {
            throw ConfigurationValidationError.noDeviceSelected
        }
        
        guard let selectedDiskBSDName = selectedDiskInfo.media.bsdName,
              let originalDiskAppearanceTime = selectedDiskInfo.media.appearanceTime else {
                  throw ConfigurationValidationError.deviceInfoUnavailable
              }
        
        let updatedDiskInfo = try DiskInspector.diskInfo(bsdName: selectedDiskBSDName)
        
        guard let updatedDiskAppearanceTime = updatedDiskInfo.media.appearanceTime,
              originalDiskAppearanceTime == updatedDiskAppearanceTime else {
                  throw ConfigurationValidationError.appearanceTimestampDiscrepancy
              }
    }
    
    static func verifyInputForCollision(_ imagePath: String, _ selectedDiskInfo: DiskInfo?) throws {
        guard let selectedDiskBSDName = selectedDiskInfo?.media.bsdName else {
            throw ConfigurationValidationError.deviceInfoUnavailable
        }
        
        guard let imageFileMountPointURL = URL(fileURLWithPath: imagePath).mountPoint else {
            throw ConfigurationValidationError.mountPointUnavailable
        }
        
        let imageFileMountPointDiskInfo = try DiskInspector.diskInfo(volumeURL: imageFileMountPointURL)
        
        guard let imageFileMountPointBSDName = imageFileMountPointDiskInfo.media.bsdName,
              imageFileMountPointBSDName != selectedDiskBSDName else {
                  throw ConfigurationValidationError.imagePathCollision
              }
    }
    
    static func verifyDiskCapacity(imageMountSystemEntity: HDIUtilSystemEntity?, selectedDiskInfo: DiskInfo?, erasedDiskVolumeURL: URL?, for checkType: CapacityCheckType) throws {
        
        guard let imageMountSystemEntity = imageMountSystemEntity else {
            throw ConfigurationValidationError.imageMountSystemEntityUnavailable
        }
        
        let imageMountDiskInfo = try DiskInspector.diskInfo(bsdName: imageMountSystemEntity.BSDMountPoint)
        
        let diskSize: UInt64 = try {
            switch checkType {
            case .rawDisk:
                guard let size = selectedDiskInfo?.media.size else {
                    throw ConfigurationValidationError.deviceInfoUnavailable
                }
                
                return size
            case .formattedVolume:
                guard let volumeURL = erasedDiskVolumeURL else {
                    throw ConfigurationValidationError.volumeInfoUnavailable
                }
                
                let attrs = try FileManager.default.attributesOfFileSystem(forPath: volumeURL.path)
                
                guard let volumeSize = attrs[.systemFreeSize] as? UInt64 else {
                    throw ConfigurationValidationError.volumeInfoUnavailable
                }
                
                return volumeSize
            }
        }()
        
        guard let imageMountSize = imageMountDiskInfo.media.size else {
            throw ConfigurationValidationError.imageInfoUnavailable
        }
        
        guard diskSize >= imageMountSize else {
            throw ConfigurationValidationError.insufficientDestinationCapacity(
                imageSize: imageMountSize,
                destinationCapacity: diskSize
            )
        }
    }
    
    enum CapacityCheckType {
        case rawDisk
        case formattedVolume
    }
}
