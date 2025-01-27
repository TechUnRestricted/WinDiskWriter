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
    private var directoryHandle: CInt?
    private var source: DispatchSourceFileSystemObject?
    
    init(url: URL) {
        self.monitoredURL = url
        startMonitoring()
    }
    
    deinit {
        stopMonitoring()
    }
    
    private func startMonitoring() {
        // Open a file descriptor for the directory
        directoryHandle = open(monitoredURL.path, O_EVTONLY)
        
        guard let handle = directoryHandle, handle != -1 else {
            print("Failed to open directory for monitoring")
            isDirectoryAccessible = false
            return
        }
        
        // Create dispatch source for directory monitoring
        let source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: handle,
            eventMask: [.revoke],
            queue: DispatchQueue.main
        )
        
        // Set up event handler
        source.setEventHandler { [weak self] in
            self?.checkDirectoryStatus()
        }
        
        // Set up cancellation handler
        source.setCancelHandler { [weak self] in
            guard let handle = self?.directoryHandle else { return }
            close(handle)
            self?.directoryHandle = nil
        }
        
        // Start monitoring
        source.resume()
        self.source = source
        
        // Perform initial check
        checkDirectoryStatus()
    }
    
    private func stopMonitoring() {
        source?.cancel()
        source = nil
        
        if let handle = directoryHandle {
            close(handle)
            directoryHandle = nil
        }
    }
    
    private func checkDirectoryStatus() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let fileManager = FileManager.default
            
            // Comprehensive directory check
            let isAccessible = fileManager.fileExists(atPath: self.monitoredURL.path) &&
            fileManager.isReadableFile(atPath: self.monitoredURL.path)
            
            if self.isDirectoryAccessible != isAccessible {
                self.isDirectoryAccessible = isAccessible
            }
        }
    }
}
