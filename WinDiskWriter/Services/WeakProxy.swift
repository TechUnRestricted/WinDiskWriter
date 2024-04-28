//
//  WeakProxy.swift
//  WinDiskWriter
//
//  Created by Macintosh on 27.04.2024.
//

import Foundation

class WeakProxy: NSObject {
    weak var target: NSObject?

    init(target: NSObject) {
        self.target = target
        super.init()
    }

    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        return target
    }
}
