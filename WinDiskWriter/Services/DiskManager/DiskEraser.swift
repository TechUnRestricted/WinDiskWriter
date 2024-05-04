//
//  DiskEraser.swift
//  WinDiskWriter
//
//  Created by Macintosh on 28.04.2024.
//

import Foundation

enum DiskEraserError: LocalizedError {
    case badBSDName
    case eraseFailedWithMessage(errorMessage: String, terminationStatus: Int32)

    var errorDescription: String? {
        switch self {
        case .badBSDName:
            return "The specified device does not correspond to a valid BSD identifier"
        case .eraseFailedWithMessage(let errorMessage, let status):
            return "Disk erasure failed with termination status \(status): \(errorMessage)"
        }
    }
}

class DiskEraser {
    private enum Constants {
        static let executablePath: String = "/usr/sbin/diskutil"
    }

    private init() { }

    static func eraseWholeDisk(bsdName: String, filesystem: Filesystem, partitionScheme: PartitonScheme, partitionName: String) throws {
        guard DiskInspector.isBSDPath(path: bsdName) else {
            throw DiskEraserError.badBSDName
        }

        try DiskInspector.validateFAT32Name(partitionName)

        let eraseArguments = [
            "eraseDisk",
            filesystem.parameterRepresentation,
            partitionName,
            partitionScheme.parameterRepresentation,
            bsdName
        ]

        let executionResult = try CommandLine.execute(
            executable: Constants.executablePath,
            arguments: eraseArguments
        )

        guard executionResult.terminationStatus == EXIT_SUCCESS else {
            let errorString = String(data: executionResult.errorData, encoding: .utf8) ?? "Unknown error"

            throw DiskEraserError.eraseFailedWithMessage(
                errorMessage: errorString.stripped(),
                terminationStatus: executionResult.terminationStatus
            )
        }
    }
}
