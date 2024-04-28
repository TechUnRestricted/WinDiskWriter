//
//  DiskMenuItem.swift
//  WinDiskWriter
//
//  Created by Macintosh on 28.04.2024.
//

import Foundation
import AppKit

class DiskMenuItem: NSMenuItem {
    let diskInfo: DiskInfo

    init?(diskInfo: DiskInfo) {
        self.diskInfo = diskInfo

        super.init(title: "", action: nil, keyEquivalent: "")

        guard setupSelf() else {
            return nil
        }
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupSelf() -> Bool {
        let deviceVendor: String = (diskInfo.deviceVendor ?? "Vendor").stripped()
        let deviceModel: String = (diskInfo.deviceModel ?? "Model").stripped()

        guard let bsdName = diskInfo.BSDName,
              let storageCapacity = diskInfo.mediaSize else {
            return false
        }

        let mutableAttributedString = NSMutableAttributedString()

        mutableAttributedString.append(
            AttributedStringBuilder(string: deviceVendor + " " + deviceModel)
                .weight(6)
                .build()
        )

        mutableAttributedString.append(
            AttributedStringBuilder(string: " ")
                .build()
        )

        mutableAttributedString.append(
            AttributedStringBuilder(string: "[" + UInt64(storageCapacity).formattedSize + "]")
                .build()
        )

        mutableAttributedString.append(
            AttributedStringBuilder(string: " ")
                .build()
        )

        mutableAttributedString.append(
            AttributedStringBuilder(string: "(" + bsdName + ")")
                .weight(3)
                .fontSize(NSFont.systemFontSize / 1.2)
                .build()
        )

        attributedTitle = mutableAttributedString

        return true
    }
}
