//
//  MainCoordinator.swift
//  WinDiskWriter
//
//  Created by Macintosh on 21.04.2024.
//

import Cocoa

class MainCoordinator: Coordinator {
    func start() {
        let coordinator = DiskWriterCoordinator()
        coordinator.start()
    }
}
