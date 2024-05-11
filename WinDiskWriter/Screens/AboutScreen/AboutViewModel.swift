//
//  AboutViewModel.swift
//  WinDiskWriter
//
//  Created by Macintosh on 11.05.2024.
//

import Foundation

final class AboutViewModel: NSObject {
    private let coordinator: AboutCoordinator

    init(coordinator: AboutCoordinator) {
        self.coordinator = coordinator

        super.init()
    }
}
