//
//  DevicePickerMenuItemsTransformer.swift
//  WinDiskWriter
//
//  Created by Macintosh on 10.05.2024.
//

import Foundation

extension NSValueTransformerName {
    static let devicePickerMenuItemsTransformerName = NSValueTransformerName(rawValue: DevicePickerMenuItemsTransformer.className())
}

class DevicePickerMenuItemsTransformer: ValueTransformer {
    override class func transformedValueClass() -> AnyClass {
        return NSArray.self
    }

    override class func allowsReverseTransformation() -> Bool {
        return false
    }

    override func transformedValue(_ value: Any?) -> Any? {
        guard let diskInfoList = value as? NSArray else {
            return nil
        }

        let menuItemsList = NSMutableArray()

        for diskInfo in diskInfoList {
            guard let castedDiskInfo = diskInfo as? DiskInfo else {
                continue
            }

            guard let diskMenuItem = DiskMenuItem(diskInfo: castedDiskInfo) else {
                continue
            }
            
            menuItemsList.add(diskMenuItem)
        }

        return menuItemsList
    }
}

