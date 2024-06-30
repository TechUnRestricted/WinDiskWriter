//
//  DiskWriter.swift
//  WinDiskWriter
//
//  Created by Macintosh on 26.05.2024.
//

import Foundation

class DiskWriter {
    struct ProgressUpdate {
        let size: UInt64
        let written: UInt64
    }

    enum ErrorHandling {
        case skip
        case stop
    }

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

    func requestStop() {
        shouldStop = true
    }

    private func stop() {
        completion()
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
}

private extension DiskWriter {
    func processOperations(_ operations: [DiskOperation]) {
        for operation in operations {
            if shouldStop { break }

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

        stop()
    }

    func handleCreateDirectory(origin: URL, destination: URL) {
        print("Creating directory from \(origin) to \(destination)")
    }

    func handleWriteFile(origin: URL, destination: URL) {
        print("Writing file from \(origin) to \(destination)")
    }

    func handleRemoveFile(path: URL) {
        print("Removing file at \(path)")
    }

    func handleWriteBytes(origin: URL, range: ClosedRange<Int>) {
        print("Writing bytes from \(origin) with range \(range)")
    }

    func handleWimExtract(origin: URL, file: URL, destination: URL) {
        print("Extracting file \(file) from \(origin) to \(destination)")
    }

    func handleWimUpdateProperty(path: URL, key: String, value: String) {
        print("Updating property \(key) with value \(value) at \(path)")
    }

    func handleWimConvertToWim(origin: URL, destination: URL) {
        print("Converting \(origin) to WIM at \(destination)")
    }
}
