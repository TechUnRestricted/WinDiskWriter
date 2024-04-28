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
    
    private init(bsdName: String) throws {
        guard let allocatedSession = DASessionCreate(kCFAllocatorDefault) else {
            throw DiskInspectorError.sessionCreationFailed
        }
        
        guard let createdDiskReference = DADiskCreateFromBSDName(kCFAllocatorDefault, allocatedSession, bsdName) else {
            throw DiskInspectorError.diskReferenceCreationFailed
        }
        
        diskSession = allocatedSession
        currentDisk = createdDiskReference
    }
}

extension DiskInspector {
    static func diskInfo(bsdName: String) throws -> DiskInfo {
        let instance = try DiskInspector(bsdName: bsdName)
        
        guard let diskDescription = DADiskCopyDescription(instance.currentDisk) as NSDictionary? else {
            throw DiskInspectorError.diskCopyDescriptionFailed
        }

        guard let isWholeDrive = diskDescription["DAMediaWhole"] as? Bool,
              let isInternal = diskDescription["DADeviceInternal"] as? Bool,
              let isMountable = diskDescription["DAVolumeMountable"] as? Bool,
              let isRemovable = diskDescription["DAMediaRemovable"] as? Bool,
              let isDeviceUnit = diskDescription["DADeviceUnit"] as? Bool,
              let isWritable = diskDescription["DAMediaWritable"] as? Bool,
              let isEncrypted = diskDescription["DAMediaEncrypted"] as? Bool,
              let isNetworkVolume = diskDescription["DAVolumeNetwork"] as? Bool,
              let isEjectable = diskDescription["DAMediaEjectable"] as? Bool else {
                  throw DiskInspectorError.diskCopyDescriptionFailed
              }
        
        let diskInfo = DiskInfo(
            isWholeDrive: isWholeDrive,
            isInternal: isInternal,
            isMountable: isMountable,
            isRemovable: isRemovable,
            isDeviceUnit: isDeviceUnit,
            isWritable: isWritable,
            isEncrypted: isEncrypted,
            isNetworkVolume: isNetworkVolume,
            isEjectable: isEjectable,
            BSDUnit: diskDescription["DAMediaBSDUnit"] as? Int,
            mediaSize: diskDescription["DAMediaSize"] as? Int,
            mediaBSDMajor: diskDescription["DAMediaBSDMajor"] as? Int,
            mediaBSDMinor: diskDescription["DAMediaBSDMinor"] as? Int,
            blockSize: diskDescription["DAMediaBlockSize"] as? Int,
            appearanceTime: diskDescription["DAAppearanceTime"] as? TimeInterval,
            devicePath: diskDescription["DADevicePath"] as? String,
            deviceModel: diskDescription["DADeviceModel"] as? String,
            BSDName: diskDescription["DAMediaBSDName"] as? String,
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
