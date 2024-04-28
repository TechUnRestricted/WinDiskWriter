//
//  DiskWriterCoordinator.swift
//  WinDiskWriter
//
//  Created by Macintosh on 21.04.2024.
//

import Cocoa

final class DiskWriterCoordinator: Coordinator {
    private var window: BaseWindow?
    private var viewController: DiskWriterViewController?

    func start() {
        let viewModel = DiskWriterViewModel(coordinator: self)
        viewController = DiskWriterViewController(viewModel: viewModel)

        let baseWindow = BaseWindow(contentViewController: viewController!)
        baseWindow.isMovableByWindowBackground = true

        baseWindow.center()
        baseWindow.makeKeyAndOrderFront(nil)

        window = baseWindow
    }

    func showFileSelectionSheet(completion: @escaping (String) -> (Void)) {
        guard let window = window else {
            return
        }

        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = true
        openPanel.allowedFileTypes = ["iso"]

        openPanel.beginSheetModal(for: window) { response in
            guard response == .OK, let selectedPath = openPanel.url?.path else {
                return
            }

            completion(selectedPath)
        }
    }
}
