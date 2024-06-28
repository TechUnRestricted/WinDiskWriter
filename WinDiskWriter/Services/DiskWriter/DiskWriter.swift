//
//  DiskWriter.swift
//  WinDiskWriter
//
//  Created by Macintosh on 26.05.2024.
//

import Foundation

struct DiskWriterConfiguration {
    let sourceURL: URL
    let destinationURL: URL

    let is64BitFilesystem: Bool

    let patchInstallerRequirements: Bool
    let installLegacyBootSector: Bool
}

class DiskWriter {
    enum ActionHandler {
        case shouldContinue
        case shouldStop
        case shouldSkip
    }

    let configuration: DiskWriterConfiguration

    private init(configuration: DiskWriterConfiguration) {
        self.configuration = configuration
    }

    static func write(
        with configuration: DiskWriterConfiguration,
        async: Bool = true,
        actionHandler: @escaping (DiskWriterActionType) -> ActionHandler,
        onCompletion: @escaping () -> (Void)
    ) {
        // let instance = DiskWriter(configuration: configuration)


    }
}

extension DiskWriter {
    func processDirectory(at url: URL) throws -> [WriteOperation]? {
        var operations: [WriteOperation] = []

        let directoryContents = try FileManager.default.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        )

        for directoryContent in directoryContents {
            switch directoryContent.pathType {
            case .directory:
                let children = try processDirectory(at: directoryContent)

                operations.append(.createFolder(
                    destination: configuration.destinationURL.appendingPathComponent(directoryContent.lastPathComponent),
                    children: children
                ))
            case .file:
                operations.append(
                    .copyFile(
                        source: directoryContent,
                        destination: configuration.destinationURL.appendingPathComponent(directoryContent.lastPathComponent)
                    )
                )
            case .unknown, .symbolicLink:
                continue
            }
        }

        return operations.isEmpty ? nil : operations
    }
}
