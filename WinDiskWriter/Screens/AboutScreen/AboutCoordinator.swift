//
//  AboutCoordinator.swift
//  WinDiskWriter
//
//  Created by Macintosh on 11.05.2024.
//

import Cocoa

final class AboutCoordinator: Coordinator {
    private weak var window: BaseWindow?
    private weak var viewController: AboutViewController?

    func start() {
        let aboutViewModel = AboutViewModel(coordinator: self)

        let aboutViewController = AboutViewController(viewModel: aboutViewModel)
        viewController = aboutViewController

        let baseWindow = BaseWindow(contentViewController: aboutViewController)
        window = baseWindow

        baseWindow.isMovableByWindowBackground = true

        baseWindow.center()
        baseWindow.makeKeyAndOrderFront(nil)
    }
}
