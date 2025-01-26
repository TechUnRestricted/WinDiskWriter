//
//  HDIUtil.swift
//  WinDiskWriter
//
//  Created by Macintosh on 22.12.2024.
//

import Foundation

// MARK: - Constants
private enum Constants {
    static let hdiutilPath = "/usr/bin/hdiutil"
}

/// A utility class for working with disk images using `hdiutil`.
enum HDIUtil {
    static func attach(imageURL: URL, options: AttachOptions = AttachOptions()) async throws -> HDIUtilAttachResult {
        var arguments = ["attach", imageURL.path(percentEncoded: false)]
        arguments += options.toArguments()

        let output = try await CommandLine.execute(executablePath: Constants.hdiutilPath, arguments: arguments)

        guard let data = output.data(using: .utf8) else {
            throw HDIUtilError.attachFailed(LocalizedStringResource("Failed to parse output as data.").stringValue)
        }

        let decoder = PropertyListDecoder()
        do {
            return try decoder.decode(HDIUtilAttachResult.self, from: data)
        } catch {
            throw HDIUtilError.attachFailed(LocalizedStringResource("Failed to decode plist output: \(error.localizedDescription)").stringValue)
        }
    }

    static func detach(device: String, force: Bool = false) async throws {
        var arguments = ["detach", device]
        if force { arguments.append("-force") }

        do {
            _ = try await CommandLine.execute(executablePath: Constants.hdiutilPath, arguments: arguments)
        } catch {
            throw HDIUtilError.detachFailed(error.localizedDescription)
        }
    }
}
