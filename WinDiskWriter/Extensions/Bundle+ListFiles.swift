//
//  Bundle+ListFiles.swift
//  WinDiskWriter
//
//  Created by Macintosh on 12.05.2024.
//

import Foundation

extension Bundle {
    enum DirectoryError: LocalizedError {
        case directoryNotFound
        case cannotAccessContents
        case unspecified(Error)

        var errorDescription: String? {
            switch self {
            case .directoryNotFound:
                return "The specified directory could not be found."
            case .cannotAccessContents:
                return "The contents of the directory cannot be accessed."
            case .unspecified(let error):
                return error.localizedDescription
            }
        }
    }

    static func listFiles(in directory: String, withExtension fileExtension: String? = nil) throws -> [URL] {
        guard let directoryURL = main.url(forResource: directory, withExtension: nil) else {
            throw DirectoryError.directoryNotFound
        }

        do {
            let fileManager = FileManager.default

            let fileURLs = try fileManager.contentsOfDirectory(
                at: directoryURL,
                includingPropertiesForKeys: nil
            )

            let filteredFileURLs = fileURLs.filter { file in
                guard let fileExtension = fileExtension else {
                    return true
                }

                return file.pathExtension == fileExtension
            }.filter {
                $0.lastPathComponent != ".DS_Store"
            }

            return filteredFileURLs
        } catch {
            throw DirectoryError.unspecified(error)
        }
    }
}
