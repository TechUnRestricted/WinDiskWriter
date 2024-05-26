//
//  DiskWriter.swift
//  WinDiskWriter
//
//  Created by Macintosh on 26.05.2024.
//

import Foundation

class DiskWriter {
    let sourceURL: URL
    let destinationURL: URL

    let is64BitFilesystem: Bool

    let patchInstallerRequirements: Bool
    let installLegacyBootSector: Bool

    weak var delegate: DiskWriterDelegate?

    private(set) var isProcessRunning = false {
        didSet {
            if !isProcessRunning {
                isCancellationScheduled = false
            }
        }
    }

    private(set) var isCancellationScheduled = false

    private(set) var writeOperations: [WriteOperation] = []

    private let dispatchQueue = DispatchQueue(label: "DiskWriter Queue")

    init(sourceURL: URL, destinationURL: URL, is64BitFilesystem: Bool, patchInstallerRequirements: Bool, installLegacyBootSector: Bool) {
        self.sourceURL = sourceURL
        self.destinationURL = destinationURL

        self.is64BitFilesystem = is64BitFilesystem

        self.patchInstallerRequirements = patchInstallerRequirements
        self.installLegacyBootSector = installLegacyBootSector
    }

    func start() throws {
        guard !isProcessRunning else {
            throw DiskWriterError.processAlreadyRunning
        }

        isProcessRunning = true

        dispatchQueue.async { [weak self] in
            guard let self = self else { return }

            defer { self.isProcessRunning = false }

            self.initializeQueue()
        }
    }

    func stop() {

    }
}

extension DiskWriter {
    private func initializeQueue() {
        writeOperations = []

        // ...
    }

    private func executeQueue() {
        // ...
    }
}
