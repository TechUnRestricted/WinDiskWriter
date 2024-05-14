//
//  DiskInspector.swift
//  WinDiskWriter
//
//  Created by Macintosh on 28.04.2024.
//

import Foundation
import DiskArbitration

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

        // Required to handle the Swift compiler Core Foundation casting bug.

        let volumeUUID: UUID? = {
            guard let genericCoreFounationType = diskDescription[kDADiskDescriptionVolumeUUIDKey] as CFTypeRef? else {
                return nil
            }

            let extractedUUID = (genericCoreFounationType as? CFUUID?)
                    .flatMap { CFUUIDCreateString(nil, $0) as String? }
                    .flatMap { UUID(uuidString: $0) }

            return extractedUUID
        }()

        let mediaUUID: UUID? = {
            guard let genericCoreFounationType = diskDescription[kDADiskDescriptionMediaUUIDKey] as CFTypeRef? else {
                return nil
            }

            let extractedUUID = (genericCoreFounationType as? CFUUID?)
                    .flatMap { CFUUIDCreateString(nil, $0) as String? }
                    .flatMap { UUID(uuidString: $0) }

            return extractedUUID
        }()

        let diskInfo = DiskInfo(
            volume: .init(
                kind: diskDescription[kDADiskDescriptionVolumeKindKey] as? String,
                isMountable: diskDescription[kDADiskDescriptionVolumeMountableKey] as? Bool,
                name: diskDescription[kDADiskDescriptionVolumeNameKey] as? String,
                isNetwork: diskDescription[kDADiskDescriptionVolumeNetworkKey] as? Bool,
                path: diskDescription[kDADiskDescriptionVolumePathKey] as? URL,
                type: diskDescription[kDADiskDescriptionVolumeTypeKey] as? String,
                uuid: volumeUUID
            ),
            media: .init(
                appearanceTime: diskDescription["DAAppearanceTime"] as? TimeInterval,
                blockSize: diskDescription[kDADiskDescriptionMediaBlockSizeKey] as? Int,
                bsdMajor: diskDescription[kDADiskDescriptionMediaBSDMajorKey] as? Int,
                bsdMinor: diskDescription[kDADiskDescriptionMediaBSDMinorKey] as? Int,
                bsdName: diskDescription[kDADiskDescriptionMediaBSDNameKey] as? String,
                bsdUnit: diskDescription[kDADiskDescriptionMediaBSDUnitKey] as? Int,
                content: diskDescription[kDADiskDescriptionMediaContentKey] as? String,
                isEjectable: diskDescription[kDADiskDescriptionMediaEjectableKey] as? Bool,
                kind: diskDescription[kDADiskDescriptionMediaKindKey] as? String,
                isLeaf: diskDescription[kDADiskDescriptionMediaLeafKey] as? Bool,
                name: diskDescription[kDADiskDescriptionMediaNameKey] as? String,
                path: diskDescription[kDADiskDescriptionMediaPathKey] as? String,
                isRemovable: diskDescription[kDADiskDescriptionMediaRemovableKey] as? Bool,
                size: diskDescription[kDADiskDescriptionMediaSizeKey] as? Int,
                type: diskDescription[kDADiskDescriptionMediaTypeKey] as? String,
                uuid: mediaUUID,
                isWhole: diskDescription[kDADiskDescriptionMediaWholeKey] as? Bool,
                isWritable: diskDescription[kDADiskDescriptionMediaWritableKey] as? Bool,
                isEncrypted: diskDescription[kDADiskDescriptionMediaEncryptedKey] as? Bool,
                encryptionDetail: diskDescription[kDADiskDescriptionMediaEncryptionDetailKey] as? Int
            ),
            device: .init(
                guid: diskDescription[kDADiskDescriptionDeviceGUIDKey] as? Data,
                isInternal: diskDescription[kDADiskDescriptionDeviceInternalKey] as? Bool,
                model: diskDescription[kDADiskDescriptionDeviceModelKey] as? String,
                path: diskDescription[kDADiskDescriptionDevicePathKey] as? String,
                protocol: diskDescription[kDADiskDescriptionDeviceProtocolKey] as? String,
                revision: diskDescription[kDADiskDescriptionDeviceRevisionKey] as? String,
                unit: diskDescription[kDADiskDescriptionDeviceUnitKey] as? Int,
                vendor: diskDescription[kDADiskDescriptionDeviceVendorKey] as? String,
                isTDMLocked: diskDescription[kDADiskDescriptionDeviceTDMLockedKey] as? Bool
            ),
            bus: .init(
                name: diskDescription[kDADiskDescriptionBusNameKey] as? String,
                path: diskDescription[kDADiskDescriptionBusPathKey] as? String
            )
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
