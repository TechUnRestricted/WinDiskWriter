//
//  NSView+makeConstraints.swift
//  WinDiskWriter
//
//  Created by Macintosh on 21.04.2024.
//

import Cocoa

extension NSView {
    func makeConstraints(translates: Bool = false, _ closure: (ConstraintMaker) -> Void) {
        translatesAutoresizingMaskIntoConstraints = translates

        let maker = ConstraintMaker(view: self)
        closure(maker)
    }
}
