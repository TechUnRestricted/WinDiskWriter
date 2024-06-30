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
    private let errorHandler: ErrorHandler

    private let fileManager = FileManager()
    private let bufferSize = Int(StorageSize.megabytes(count: 4))

    private var shouldStop: Bool = false

    private init(
        progressUpdate: @escaping ProgressHandler,
        process: @escaping OperationHandler,
        error: @escaping ErrorHandler,
        completion: @escaping CompletionHandler
    ) {
        self.progressUpdate = progressUpdate
        self.process = process
        self.errorHandler = error
        self.completion = completion
    }

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

    private func processOperations(_ operations: [DiskOperation]) {
        for operation in operations {
            if shouldStop { break }

            process(operation)

            switch operation {
            case .createDirectory(let path):
                handleCreateDirectory(path: path)
            case .writeFile(let origin, let destination):
                handleWriteFile(origin: origin, destination: destination)
            case .removeFile(let path):
                handleRemoveFile(path: path)
            case .writeBytes(let origin, let range):
                handleWriteBytes(origin: origin, range: range)
            case .wimSplit(origin: let origin, destination: let destination):
                handleWimSplit(origin: origin, destination: destination)
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

    private func handleOperationError(_ error: Error) {
        let shouldStop = (errorHandler(error) == .stop)

        if shouldStop {
            requestStop()
        }
    }
}

private extension DiskWriter {
    func handleCreateDirectory(path: URL) {
        do {
            try fileManager.createDirectory(
                at: path,
                withIntermediateDirectories: true,
                attributes: nil
            )
        } catch {
            handleOperationError(error)
        }
    }

    func handleWriteFile(origin: URL, destination: URL) {
        guard let inputStream = InputStream(url: origin) else {
            handleOperationError(DiskWriterError.cannotOpenInputFile)
            return
        }

        guard let outputStream = OutputStream(url: destination, append: false) else {
            handleOperationError(DiskWriterError.cannotOpenOutputFile)
            return
        }

        inputStream.open()
        defer { inputStream.close() }

        outputStream.open()
        defer { outputStream.close() }

        guard let fileSize = fileManager.fileSize(at: origin.path) else {
            handleOperationError(DiskWriterError.cannotDetermineFileSize)
            return
        }

        var buffer = [UInt8](repeating: 0, count: bufferSize)
        var totalBytesWritten: UInt64 = 0

        if shouldStop { return }

        while inputStream.hasBytesAvailable {
            if shouldStop { return }

            let bytesRead = inputStream.read(&buffer, maxLength: buffer.count)
            if bytesRead < 0 {
                handleOperationError(DiskWriterError.errorReadingFile(inputStream.streamError?.localizedDescription))
                break
            }

            if bytesRead == 0 {
                break
            }

            let bytesWritten = outputStream.write(buffer, maxLength: bytesRead)
            if bytesWritten < 0 {
                handleOperationError(DiskWriterError.errorWritingFile(outputStream.streamError?.localizedDescription))
                break
            }

            totalBytesWritten += UInt64(bytesWritten)

            let progress = ProgressUpdate(size: fileSize, written: totalBytesWritten)
            progressUpdate(progress)

            if shouldStop { return }
        }
    }

    func handleRemoveFile(path: URL) {
        do {
            try fileManager.removeItem(at: path)
        } catch {
            handleOperationError(error)
        }
    }

    func handleWriteBytes(origin: URL, range: ClosedRange<Int>) {

    }

    func handleWimSplit(origin: URL, destination: URL) {

    }

    func handleWimExtract(origin: URL, file: URL, destination: URL) {

    }

    func handleWimUpdateProperty(path: URL, key: String, value: String) {

    }

    func handleWimConvertToWim(origin: URL, destination: URL) {

    }
}
