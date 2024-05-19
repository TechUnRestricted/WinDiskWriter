//
//  DiskEraser.swift
//  WinDiskWriter
//
//  Created by Macintosh on 28.04.2024.
//

import Foundation

class DiskEraser {
    private enum Constants {
        static let executablePath: String = "/usr/sbin/diskutil"
    }

    private init() { }

    static func generateFAT32Name(prefix: String? = nil, suffix: String? = nil, randomCharLimit: Int) -> String {
        let characters = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
        let maxLength = 11

        let prefixCount = prefix?.count ?? 0
        let suffixCount = suffix?.count ?? 0

        let randomCharsCount = min(randomCharLimit, maxLength - prefixCount - suffixCount)

        let randomChars = (0..<randomCharsCount).compactMap { _ in
            characters.randomElement()
        }

        let name = (prefix ?? "") + randomChars + (suffix ?? "")

        return String(name.prefix(maxLength)).uppercased()
    }

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
