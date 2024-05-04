//
//  HDIUtil.swift
//  WinDiskWriter
//
//  Created by Macintosh on 28.04.2024.
//

import Foundation

enum HDIUtilError: LocalizedError {
    case systemEntitiesNotFound
    case systemEntitiesIsEmpty
    case systemEntitiesCountMoreThanOne

    var errorDescription: String? {
        switch self {
        case .systemEntitiesNotFound:
            return "System entities could not be found in the decoded property list"
        case .systemEntitiesIsEmpty:
            return "The 'system-entities' array is empty"
        case .systemEntitiesCountMoreThanOne:
            return "The 'system-entities' array contains more than one entry"
        }
    }
}

class HDIUtil {
    private enum Constants {
        static let executablePath: String = "/usr/bin/hdiutil"
    }

    static func attachImage(imagePath: String, additionalArguments: [String]? = nil) throws -> HDIUtilSystemEntity {
        var localArgumentsArray = [
            "attach",
            imagePath,
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
