//
//  ActionButtonTitleTransformer.swift
//  WinDiskWriter
//
//  Created by Macintosh on 08.05.2024.
//

import Foundation

extension NSValueTransformerName {
    static let actionButtonTitleTransformerName = NSValueTransformerName(rawValue: ActionButtonTitleTransformer.className())
}

class ActionButtonTitleTransformer: ValueTransformer {
    override class func transformedValueClass() -> AnyClass {
        return NSString.self
    }

    override class func allowsReverseTransformation() -> Bool {
        return false
    }

    override func transformedValue(_ value: Any?) -> Any? {
        guard let isIdle = value as? Bool else {
            return nil
        }

        return isIdle ? "Start" : "Stop"
    }
}
