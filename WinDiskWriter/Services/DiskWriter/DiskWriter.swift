//
//  DiskWriter.swift
//  WinDiskWriter
//
//  Created by Macintosh on 26.05.2024.
//

import Foundation

enum ErrorHandling {
    case skip
    case stop
}

enum DiskOperation {
    case createDirectory(origin: URL, destination: URL)
    case writeFile(origin: URL, destination: URL)
    case removeFile(path: URL)
    case writeBytes(origin: URL, range: ClosedRange<Int>)
    case wimExtract(origin: URL, file: URL, destination: URL)
    case wimUpdateProperty(path: URL, key: String, value: String)
    case wimConvertToWim(origin: URL, destination: URL)
    case subQueue(operations: [DiskOperation])

    static func createQueue(with url: URL) -> [DiskOperation] {
        return [
            .createDirectory(origin: url, destination: url.appendingPathComponent("NewDirectory")),
            .writeFile(origin: url.appendingPathComponent("source.txt"), destination: url.appendingPathComponent("destination.txt")),
            .subQueue(operations: [
                .removeFile(path: url.appendingPathComponent("oldFile.txt")),
                .writeBytes(origin: url.appendingPathComponent("data.bin"), range: 0...100)
            ])
        ]
    }
}

struct ProgressUpdate {
    let size: UInt64
    let written: UInt64
}

class DiskWriter {
    typealias OperationHandler = ((DiskOperation) -> Void)
    typealias ProgressHandler = ((ProgressUpdate) -> Void)
    typealias ErrorHandler = ((Error) -> ErrorHandling)
    typealias CompletionHandler = (() -> Void)

    private let process: OperationHandler
    private let completion: CompletionHandler
    private let progressUpdate: ProgressHandler
    private let error: ErrorHandler

    private var shouldStop: Bool = false

    static func start(
        with queue: [DiskOperation],
        progressUpdate: @escaping ProgressHandler,
        process: @escaping OperationHandler,
        error: @escaping ErrorHandler,
        completion: @escaping CompletionHandler
    ) -> DiskWriter {
        let instance = DiskWriter(progressUpdate: progressUpdate, process: process, error: error, completion: completion)
        instance.processOperations(queue)

        return instance
    }

    private init(
        progressUpdate: @escaping ProgressHandler,
        process: @escaping OperationHandler,
        error: @escaping ErrorHandler,
        completion: @escaping CompletionHandler
    ) {
        self.progressUpdate = progressUpdate
        self.process = process
        self.error = error
        self.completion = completion
    }

    private func processOperations(_ operations: [DiskOperation]) {
        for operation in operations {
            switch operation {
            case .createDirectory(let origin, let destination):
                handleCreateDirectory(origin: origin, destination: destination)
            case .writeFile(let origin, let destination):
                handleWriteFile(origin: origin, destination: destination)
            case .removeFile(let path):
                handleRemoveFile(path: path)
            case .writeBytes(let origin, let range):
                handleWriteBytes(origin: origin, range: range)
            case .wimExtract(let origin, let file, let destination):
                handleWimExtract(origin: origin, file: file, destination: destination)
            case .wimUpdateProperty(let path, let key, let value):
                handleWimUpdateProperty(path: path, key: key, value: value)
            case .wimConvertToWim(let origin, let destination):
                handleWimConvertToWim(origin: origin, destination: destination)
            case .subQueue(let operations):
                processOperations(operations)
            }
        }
    }

    private func handleCreateDirectory(origin: URL, destination: URL) {
        print("Creating directory from \(origin) to \(destination)")
    }

    private func handleWriteFile(origin: URL, destination: URL) {
        print("Writing file from \(origin) to \(destination)")
    }

    private func handleRemoveFile(path: URL) {
        print("Removing file at \(path)")
    }

    private func handleWriteBytes(origin: URL, range: ClosedRange<Int>) {
        print("Writing bytes from \(origin) with range \(range)")
    }

    private func handleWimExtract(origin: URL, file: URL, destination: URL) {
        print("Extracting file \(file) from \(origin) to \(destination)")
    }

    private func handleWimUpdateProperty(path: URL, key: String, value: String) {
        print("Updating property \(key) with value \(value) at \(path)")
    }

    private func handleWimConvertToWim(origin: URL, destination: URL) {
        print("Converting \(origin) to WIM at \(destination)")
    }
}
