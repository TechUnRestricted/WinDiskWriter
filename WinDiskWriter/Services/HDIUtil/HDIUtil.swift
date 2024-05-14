//
//  HDIUtil.swift
//  WinDiskWriter
//
//  Created by Macintosh on 28.04.2024.
//

import Foundation

class HDIUtil {
    private enum Constants {
        static let executablePath: String = "/usr/bin/hdiutil"
    }

    private init() { }

    static func attachImage(imageURL: URL, additionalArguments: [String]? = nil) throws -> HDIUtilSystemEntity {
        var localArgumentsArray = [
            "attach",
            imageURL.path,
            "-plist"
        ]

        if let additionalArguments = additionalArguments {
            localArgumentsArray.append(contentsOf: additionalArguments)
        }

        let commandLineResult = try CommandLine.execute(
            executable: Constants.executablePath,
            arguments: localArgumentsArray
        )

        let decoder = PropertyListDecoder()

        let decodedPlist = try decoder.decode(
            HDIUtilImageMountResult.self,
            from: commandLineResult.standardData
        )

        guard let systemEntities = decodedPlist.systemEntities else {
            throw HDIUtilError.systemEntitiesNotFound
        }

        guard !systemEntities.isEmpty else {
            throw HDIUtilError.systemEntitiesIsEmpty
        }

        guard systemEntities.count == 1,
              let requiredSystemEntity = systemEntities.last else {
            throw HDIUtilError.systemEntitiesCountMoreThanOne
        }

        return requiredSystemEntity
    }
}
