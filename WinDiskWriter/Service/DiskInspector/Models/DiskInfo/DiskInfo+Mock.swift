//
//  DiskInfo+Mock.swift
//  WinDiskWriter
//
//  Created by Macintosh on 29.12.2024.
//

extension DiskInfo {
    /// Creates a mock DiskInfo instance with realistic test data
    static func mock(
        isExternal: Bool = true,
        isEjectable: Bool = true,
        isRemovable: Bool = true,
        isWhole: Bool = true,
        size: UInt64 = 1024 * 1024 * 1024 * 64 // 64GB
    ) -> DiskInfo {
        // Generate a stable UUID for testing
        let mockUUID = UUID(uuidString: "33C86F0F-C3F3-4BB8-8FF9-B6560F654321")!
        
        let volume = Volume(
            kind: "apfs",
            isMountable: true,
            name: "Test Drive",
            isNetwork: false,
            path: URL(string: "file:///Volumes/Test%20Drive"),
            type: "msdos",
            uuid: mockUUID
        )
        
        let media = Media(
            appearanceTime: Date().timeIntervalSince1970,
            blockSize: 512,
            bsdMajor: 1,
            bsdMinor: 2,
            bsdName: "disk4",
            bsdUnit: 4,
            content: "GUID_partition_scheme",
            isEjectable: isEjectable,
            kind: "APPLE SSD",
            isLeaf: true,
            name: "External USB Drive",
            path: "/dev/disk4",
            isRemovable: isRemovable,
            size: size,
            type: "USB",
            uuid: mockUUID,
            isWhole: isWhole,
            isWritable: true,
            isEncrypted: false,
            encryptionDetail: 0
        )
        
        let device = Device(
            guid: "TEST-GUID-1234".data(using: .utf8),
            isInternal: !isExternal,
            model: "SanDisk Ultra",
            path: "IOService:/AppleACPIPlatformExpert/PCI0@0/AppleACPIPCI/XHC1@14",
            protocol: "USB",
            revision: "1.0",
            unit: 0,
            vendor: "SanDisk",
            isTDMLocked: false
        )
        
        let bus = Bus(
            name: "USB",
            path: "IOService:/AppleACPIPlatformExpert/PCI0@0/AppleACPIPCI/XHC1@14"
        )
        
        return DiskInfo(
            volume: volume,
            media: media,
            device: device,
            bus: bus
        )
    }
    
    /// Creates an array of mock DiskInfo instances for testing
    static func mockArray(count: Int = 3) -> [DiskInfo] {
        let vendors = ["SanDisk", "Samsung", "Western Digital", "Seagate", "Kingston"]
        let models = ["Ultra", "T7", "Elements", "Backup Plus", "DataTraveler"]
        let sizes: [UInt64] = [
            32 * 1024 * 1024 * 1024,  // 32GB
            64 * 1024 * 1024 * 1024,  // 64GB
            128 * 1024 * 1024 * 1024, // 128GB
            256 * 1024 * 1024 * 1024, // 256GB
            512 * 1024 * 1024 * 1024  // 512GB
        ]
        
        return (0..<count).map { index in
            let mockDisk = mock(
                isExternal: true,
                isEjectable: true,
                isRemovable: true,
                isWhole: true,
                size: sizes[index % sizes.count]
            )
            
            // Customize each disk
            mockDisk.device.vendor = vendors[index % vendors.count]
            mockDisk.device.model = models[index % models.count]
            mockDisk.media.bsdName = "disk\(index + 1)"
            mockDisk.volume.name = "\(mockDisk.device.vendor ?? "Unknown") \(mockDisk.device.model ?? "Drive")"
            
            return mockDisk
        }
    }
    
    /// Creates a mock internal system disk for testing
    static func mockSystemDisk() -> DiskInfo {
        let disk = mock(
            isExternal: false,
            isEjectable: false,
            isRemovable: false,
            isWhole: true,
            size: 512 * 1024 * 1024 * 1024 // 512GB
        )
        
        disk.device.vendor = "Apple"
        disk.device.model = "MacBook SSD"
        disk.media.bsdName = "disk0"
        disk.volume.name = "Macintosh HD"
        disk.media.content = "Apple_APFS"
        disk.volume.type = "apfs"
        
        return disk
    }
}
