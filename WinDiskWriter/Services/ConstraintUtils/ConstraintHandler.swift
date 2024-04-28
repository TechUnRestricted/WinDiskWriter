//
//  ConstraintHandler.swift
//  WinDiskWriter
//
//  Created by Macintosh on 21.04.2024.
//

import Cocoa

class ConstraintHandler {
    private(set) var constraints: [NSLayoutConstraint]

    init(constraints: [NSLayoutConstraint]) {
        self.constraints = constraints
    }

    func enable() {
        NSLayoutConstraint.activate(constraints)
    }

    func disable() {
        NSLayoutConstraint.deactivate(constraints)
    }
}
