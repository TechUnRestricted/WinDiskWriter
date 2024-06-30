//
//  DiskOperation.swift
//  WinDiskWriter
//
//  Created by Macintosh on 30.06.2024.
//

import Foundation

enum DiskOperation {
    case createDirectory(path: URL)
    case writeFile(origin: URL, destination: URL)
    case removeFile(path: URL)
    case writeBytes(origin: URL, range: ClosedRange<Int>)
    case wimExtract(origin: URL, file: URL, destination: URL)
    case wimSplit(origin: URL, destination: URL)
    case wimUpdateProperty(path: URL, key: String, value: String)
    case wimConvertToWim(origin: URL, destination: URL)
    case subQueue(operations: [DiskOperation])

    static func createQueue(with url: URL) -> [DiskOperation] {
        return [
            .createDirectory(path: url.appendingPathComponent("NewDirectory")),
            .writeFile(origin: url.appendingPathComponent("source.txt"), destination: url.appendingPathComponent("destination.txt")),
            .subQueue(operations: [
                .removeFile(path: url.appendingPathComponent("oldFile.txt")),
                .writeBytes(origin: url.appendingPathComponent("data.bin"), range: 0...100)
            ])
        ]
    }
}
