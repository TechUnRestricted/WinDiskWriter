//
//  AboutCoordinator.swift
//  WinDiskWriter
//
//  Created by Macintosh on 11.05.2024.
//

import Foundation

final class AboutCoordinator: Coordinator {
    private var window: BaseWindow?
    private var viewController: AboutViewController?

    func start() {
        let viewModel = AboutViewModel(coordinator: self)
        viewController = AboutViewController(viewModel: viewModel)

        let baseWindow = BaseWindow(contentViewController: viewController!)
        baseWindow.isMovableByWindowBackground = true

        baseWindow.center()
        baseWindow.makeKeyAndOrderFront(nil)

        window = baseWindow
    }
}
