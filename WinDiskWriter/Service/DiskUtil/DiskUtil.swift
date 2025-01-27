//
//  DiskUtil.swift
//  WinDiskWriter
//
//  Created by Macintosh on 27.01.2025.
//

import Foundation

// MARK: - Constants
private enum Constants {
    static let diskutilPath = "/usr/sbin/diskutil"
}

/// A utility class for working with disk operations using `diskutil`.
enum DiskUtil {    
    /// Erases and formats a disk with specified parameters.
    /// - Parameters:
    ///   - device: The disk device identifier (e.g., "disk2")
    ///   - name: The name for the formatted disk
    ///   - filesystem: The filesystem type to use
    ///   - bootMode: The boot mode for partition scheme
    /// - Returns: The standard output from the diskutil command
    /// - Throws: `DiskUtilError` or `FilesystemError` if the operation fails
    static func eraseDisk(
        device: String,
        name: String,
        filesystem: Filesystem,
        bootMode: BootMode
    ) async throws -> String {
        guard !device.stripped().isEmpty else {
            throw DiskUtilError.invalidDevice
        }
        
        try filesystem.validateName(name)
        
        let partitionScheme = bootMode == .uefi ? "GPT" : "MBR"
        
        let arguments: [String] = [
            "eraseDisk",
            filesystem.name,
            name,
            partitionScheme,
            device
        ]
        
        do {
            return try await CommandLine.execute(
                executablePath: Constants.diskutilPath,
                arguments: arguments
            )
        } catch {
            throw DiskUtilError.commandFailed(error.localizedDescription)
        }
    }
}
