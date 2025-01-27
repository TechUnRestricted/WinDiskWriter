//
//  DirectoryMonitor.swift
//  WinDiskWriter
//
//  Created by Macintosh on 26.01.2025.
//

import Foundation
import Combine

class DirectoryMonitor: ObservableObject {
    @Published var isDirectoryAccessible: Bool = true

    private let monitoredURL: URL
    private let timeInterval: TimeInterval
    
    private var timer: Timer?

    init(url: URL, timeInterval: TimeInterval = 2.0) {
        self.monitoredURL = url
        self.timeInterval = timeInterval
        
        startMonitoring()
    }

    deinit {
        stopMonitoring()        
    }

    private func startMonitoring() {
        // Start periodic checks
        timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true) { [weak self] _ in
            self?.checkDirectoryStatus()
        }
        
        checkDirectoryStatus() // Initial check
    }

    private func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }

    private func checkDirectoryStatus() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.isDirectoryAccessible = self.isVolumeAvailable(for: self.monitoredURL)
        }
    }

    private func isVolumeAvailable(for url: URL) -> Bool {
        var stat = statfs()
        return statfs(url.path, &stat) == 0
    }
}
