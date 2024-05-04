//
//  DiskInspector.swift
//  WinDiskWriter
//
//  Created by Macintosh on 28.04.2024.
//

import Foundation
import DiskArbitration

enum DiskInspectorError: Error {
    case sessionCreationFailed
    case diskReferenceCreationFailed
    case diskCopyDescriptionFailed
    case unableToRetrieveServices
    case invalidFAT32Name(reason: String)
}

extension DiskInspectorError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .sessionCreationFailed:
            return "Can't create a DiskArbitration session"
        case .diskReferenceCreationFailed:
            return "Can't create a DiskArbitration disk session for the specified initializer"
        case .diskCopyDescriptionFailed:
            return "Can't extract the descriptive information from the disk"
        case .unableToRetrieveServices:
            return "Can't retrieve IO Services with specified options"
        case .invalidFAT32Name(let reason):
            return "Invalid FAT32 name: \(reason)"
        }
    }
}

class DiskInspector {
    private enum Constants {
        static let diskPrefix: String = "disk"
        static let bsdNameKey: String = "BSD Name"
        
        static let fsFAT32ValidCharacters: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 $%'-_@~`!(){}^#&"
        static let fsFAT32MaxCharCount: Int = 11
    }
    
    private let diskSession: DASession
    private let currentDisk: DADisk

    private init(disk: DADisk, session: DASession) {
        self.diskSession = session
        self.currentDisk = disk
    }

    convenience private init(volumeURL: URL) throws {
        guard let allocatedSession = DASessionCreate(kCFAllocatorDefault) else {
            throw DiskInspectorError.sessionCreationFailed
        }

        guard let createdDiskReference = DADiskCreateFromVolumePath(kCFAllocatorDefault, allocatedSession, volumeURL as CFURL) else {
            throw DiskInspectorError.diskReferenceCreationFailed
        }

        self.init(disk: createdDiskReference, session: allocatedSession)
    }

    convenience private init(bsdName: String) throws {
        guard let allocatedSession = DASessionCreate(kCFAllocatorDefault) else {
            throw DiskInspectorError.sessionCreationFailed
        }

        guard let createdDiskReference = DADiskCreateFromBSDName(kCFAllocatorDefault, allocatedSession, bsdName) else {
            throw DiskInspectorError.diskReferenceCreationFailed
        }

        self.init(disk: createdDiskReference, session: allocatedSession)
    }

    private func createDiskInfo() throws -> DiskInfo {
        guard let diskDescription = DADiskCopyDescription(currentDisk) as NSDictionary? else {
            throw DiskInspectorError.diskCopyDescriptionFailed
        }

        guard let bsdName = diskDescription["DAMediaBSDName"] as? String,
              let mediaSize = diskDescription["DAMediaSize"] as? Int,
              let appearanceTime = diskDescription["DAAppearanceTime"] as? TimeInterval else {
                  throw DiskInspectorError.diskCopyDescriptionFailed
              }

        let diskInfo = DiskInfo(
            BSDName: bsdName,
            mediaSize: mediaSize,
            appearanceTime: appearanceTime,
            BSDUnit: diskDescription["DAMediaBSDUnit"] as? Int,
            mediaBSDMajor: diskDescription["DAMediaBSDMajor"] as? Int,
            mediaBSDMinor: diskDescription["DAMediaBSDMinor"] as? Int,
            blockSize: diskDescription["DAMediaBlockSize"] as? Int,
            isWholeDrive: diskDescription["DAMediaWhole"] as? Bool,
            isInternal: diskDescription["DADeviceInternal"] as? Bool,
            isMountable: diskDescription["DAVolumeMountable"] as? Bool,
            isRemovable: diskDescription["DAMediaRemovable"] as? Bool,
            isWritable: diskDescription["DAMediaWritable"] as? Bool,
            isEncrypted: diskDescription["DAMediaEncrypted"] as? Bool,
            isNetworkVolume: diskDescription["DAVolumeNetwork"] as? Bool,
            isEjectable: diskDescription["DAMediaEjectable"] as? Bool,
            isDeviceUnit: diskDescription["DADeviceUnit"] as? Bool,
            devicePath: diskDescription["DADevicePath"] as? String,
            deviceModel: diskDescription["DADeviceModel"] as? String,
            mediaKind: diskDescription["DAMediaKind"] as? String,
            volumeKind: diskDescription["DAVolumeKind"] as? String,
            volumeName: diskDescription["DAVolumeName"] as? String,
            volumePath: diskDescription["DAVolumePath"] as? String,
            mediaPath: diskDescription["DAMediaPath"] as? String,
            mediaName: diskDescription["DAMediaName"] as? String,
            mediaContent: diskDescription["DAMediaContent"] as? String,
            busPath: diskDescription["DABusPath"] as? String,
            deviceProtocol: diskDescription["DADeviceProtocol"] as? String,
            deviceRevision: diskDescription["DADeviceRevision"] as? String,
            busName: diskDescription["DABusName"] as? String,
            deviceVendor: diskDescription["DADeviceVendor"] as? String
        )

        return diskInfo
    }
}

extension DiskInspector {
    static func diskInfo(volumeURL: URL) throws -> DiskInfo {
        let instance = try DiskInspector(volumeURL: volumeURL)

        return try instance.createDiskInfo()
    }

    static func diskInfo(bsdName: String) throws -> DiskInfo {
        let instance = try DiskInspector(bsdName: bsdName)
        
        return try instance.createDiskInfo()
    }
    
    static func getBSDDrivesNames() throws -> [String] {
        let matchingDictionary = IOServiceMatching(kIOServicePlane)
        var serviceIterator: io_iterator_t = 0
        
        guard IOServiceGetMatchingServices(kIOMasterPortDefault, matchingDictionary, &serviceIterator) == KERN_SUCCESS else {
            throw DiskInspectorError.unableToRetrieveServices
        }
        
        var BSDNames: [String] = []
        var serviceObject: io_object_t = IOIteratorNext(serviceIterator)
        
        while serviceObject != 0 {
            let propertyKey = Constants.bsdNameKey
            let options = IOOptionBits(kIORegistryIterateRecursively)
            
            let BSDNameAsCFString = IORegistryEntryCreateCFProperty(
                serviceObject,
                propertyKey as CFString,
                kCFAllocatorDefault,
                options
            )
            
            if let BSDName = BSDNameAsCFString?.takeRetainedValue() as? String, BSDName.hasPrefix(Constants.diskPrefix) {
                BSDNames.append(BSDName)
            }
            
            IOObjectRelease(serviceObject)
            
            serviceObject = IOIteratorNext(serviceIterator)
        }
        
        IOObjectRelease(serviceIterator)
        
        return BSDNames
    }
    
    static func getDisksInfoList() -> [DiskInfo] {
        var disksInfoList: [DiskInfo] = []
        
        guard let drivesList = try? DiskInspector.getBSDDrivesNames() else {
            return disksInfoList
        }
        
        for bsdName in drivesList {
            guard let diskInfo = try? DiskInspector.diskInfo(bsdName: bsdName) else {
                continue
            }
            
            disksInfoList.append(diskInfo)
        }
        
        return disksInfoList
    }
}

extension DiskInspector {
    static func isBSDPath(path: String) -> Bool {
        return path.hasOneOfThePrefixes([
            "disk", "/dev/disk",
            "rdisk", "/dev/rdisk"
        ])
    }
    
    static func validateFAT32Name(_ name: String) throws {
        let validCharacters = CharacterSet(charactersIn: Constants.fsFAT32ValidCharacters)
        
        guard name.count <= Constants.fsFAT32MaxCharCount else {
            throw DiskInspectorError.invalidFAT32Name(reason: "Name exceeds maximum character count for FAT32")
        }
        
        guard name == name.trimmingCharacters(in: .whitespaces) else {
            throw DiskInspectorError.invalidFAT32Name(reason: "Name cannot start or end with a space")
        }
        
        guard name.rangeOfCharacter(from: validCharacters.inverted) == nil else {
            throw DiskInspectorError.invalidFAT32Name(reason: "Name contains invalid characters")
        }
    }
}
