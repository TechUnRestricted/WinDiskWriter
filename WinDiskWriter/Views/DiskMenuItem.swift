//
//  DiskMenuItem.swift
//  WinDiskWriter
//
//  Created by Macintosh on 28.04.2024.
//

import Foundation
import AppKit

class DiskMenuItem: NSMenuItem {
    private enum Constants {
        static let bsdFontSize: CGFloat = NSFont.systemFontSize / 1.2
    }

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
        let deviceVendor: String = (diskInfo.device.vendor ?? "Vendor").stripped()
        let deviceModel: String = (diskInfo.device.model ?? "Model").stripped()

        guard let mediaSize = diskInfo.media.size,
              let bsdName = diskInfo.media.bsdName else {
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
            AttributedStringBuilder(string: "[" + UInt64(mediaSize).formattedSize + "]")
                .build()
        )

        mutableAttributedString.append(
            AttributedStringBuilder(string: " ")
                .build()
        )


        let sizeDifference: CGFloat = NSFont.systemFontSize - Constants.bsdFontSize
        let baselineOffset: CGFloat = sizeDifference / 2

        mutableAttributedString.append(
            AttributedStringBuilder(string: "(" + bsdName + ")")
                .weight(3)
                .fontSize(NSFont.systemFontSize / 1.2)
                .baselineOffset(baselineOffset)
                .build()
        )

        attributedTitle = mutableAttributedString

        return true
    }
}
