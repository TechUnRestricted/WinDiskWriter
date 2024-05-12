//
//  FileReader.swift
//  WinDiskWriter
//
//  Created by Macintosh on 12.05.2024.
//

import Foundation

class FileReader {
    let maxFileSize: UInt64

    init(maxFileSize: UInt64) {
        self.maxFileSize = maxFileSize
    }

    func readFile(from url: URL) throws -> Data {
        let fileAttributes = try FileManager.default.attributesOfItem(atPath: url.path)

        guard let fileSize = fileAttributes[.size] as? NSNumber else {
            throw FileReaderError.fileNotFound
        }

        guard fileSize.intValue <= maxFileSize else {
            throw FileReaderError.fileTooLarge
        }

        guard FileManager.default.isReadableFile(atPath: url.path) else {
            throw FileReaderError.fileNotReadable
        }

        return try Data(contentsOf: url)
    }
}
