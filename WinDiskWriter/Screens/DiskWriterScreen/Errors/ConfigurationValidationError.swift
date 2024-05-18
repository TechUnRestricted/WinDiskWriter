//
//  ConfigurationValidationError.swift
//  WinDiskWriter
//
//  Created by Macintosh on 03.05.2024.
//

enum ConfigurationValidationError: LocalizedError {
    case deviceInfoUnavailable
    case mountPointUnavailable
    case imageDiskInfoUnavailable
    case appearanceTimestampDiscrepancy
    case imagePathCollision
    case emptyImagePath
    case notAFile
    case fileNotFound
    case fileNotReadable
    case noDeviceSelected
    case imageMountSystemEntityUnavailable
    
    var errorDescription: String? {
        switch self {
        case .deviceInfoUnavailable:
            return "Device information could not be retrieved"
        case .mountPointUnavailable:
            return "Mount point for the selected image is unavailable"
        case .imageDiskInfoUnavailable:
            return "Disk information for the image is unavailable"
        case .appearanceTimestampDiscrepancy:
            return "Mismatch in device appearance timestamps"
        case .imagePathCollision:
            return "The image path is located on the destination device"
        case .emptyImagePath:
            return "No image path provided"
        case .notAFile:
            return "Path does not point to a file"
        case .fileNotFound:
            return "Image file could not be found"
        case .fileNotReadable:
            return "Image file is not readable"
        case .noDeviceSelected:
            return "No device has been selected"
        case .imageMountSystemEntityUnavailable:
            return "Mount system entity for the image is unavailable"
        }
    }
}

