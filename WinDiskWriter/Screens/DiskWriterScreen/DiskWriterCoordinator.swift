//
//  DiskWriterCoordinator.swift
//  WinDiskWriter
//
//  Created by Macintosh on 21.04.2024.
//

import Cocoa

final class DiskWriterCoordinator: Coordinator {
    private var window: BaseWindow?
    private var windowCloseButton: NSButton? {
        get {
            window?.standardWindowButton(.closeButton)
        }
    }

    private var viewController: DiskWriterViewController?

    func start() {
        let viewModel = DiskWriterViewModel(coordinator: self)
        viewController = DiskWriterViewController(viewModel: viewModel)

        let baseWindow = BaseWindow(contentViewController: viewController!)
        baseWindow.isMovableByWindowBackground = true

        baseWindow.center()
        baseWindow.makeKeyAndOrderFront(nil)

        window = baseWindow

        bindWindow()
    }

    private func bindWindow() {
        windowCloseButton?.bind(
            .enabled,
            to: AppService.shared,
            withKeyPath: #keyPath(AppService.isIdle),
            options: [
                .validatesImmediately: true
            ]
        )
    }

    func visitDevelopersPage() {
        URL(string: GlobalConstants.developerGitHubLink)?.open()
    }
}

extension DiskWriterCoordinator {
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

    func showRestartWithEscalatedPermissionsAlert() {
        guard let window = window else {
            return
        }

        let alertBuilder = AlertBuilder(
            title: "Restart with Administrator Privileges Required",
            subtitle: "All unsaved changes will be lost",
            image: NSImage(named: NSImage.cautionName)
        )

        alertBuilder
            .addButton(
                title: "Restart",
                preferDefault: false, handler: {
                    try? AppRelauncher.restartApp(withElevatedPermissions: true)
                }
            )
            .addButton(title: "Cancel", preferDefault: true)

        alertBuilder.show(in: window)
    }

    func showVerificationFailureWarningAlert(subtitle: String) {
        guard let window = window else {
            return
        }

        let alertBuilder = AlertBuilder(
            title: "Verification Error",
            subtitle: subtitle,
            image: NSImage(named: NSImage.cautionName)
        )

        alertBuilder.show(in: window)
    }

    func showStartWritingAlert(action: @escaping () -> ()) {
        guard let window = window else {
            return
        }

        let alertBuilder = AlertBuilder(
            title: "Start the writing process?",
            subtitle: "Proceeding will erase the disk and start the writing process",
            image: NSImage(named: NSImage.cautionName)
        )

        alertBuilder.addButton(title: "Yes", preferDefault: true) {
            action()
        }

        alertBuilder.addButton(title: "No")

        alertBuilder.show(in: window)
    }

    func showStopWritingAlert(action: @escaping () -> ()) {
        guard let window = window else {
            return
        }

        let alertBuilder = AlertBuilder(
            title: "Stop the writing process?",
            subtitle: "Proceeding will stop the writing process and may leave the disk in an unusable state",
            image: NSImage(named: NSImage.cautionName)
        )

        alertBuilder.addButton(title: "Yes") {
            action()
        }

        alertBuilder.addButton(title: "No", preferDefault: true)

        alertBuilder.show(in: window)
    }

    func showUnsafeTerminateAlert() {
        guard let window = window else {
            return
        }

        let alertBuilder = AlertBuilder(
            title: "Quit \(AppInfo.appName)?",
            subtitle: "Quitting now will interrupt the ongoing operation and may leave the disk in an unusable state",
            image: NSImage(named: NSImage.cautionName)
        )

        alertBuilder.addButton(title: "Quit", preferDefault: true) {
            AppService.terminate(self)
        }

        alertBuilder.addButton(title: "Cancel")

        alertBuilder.show(in: window)
    }
}
