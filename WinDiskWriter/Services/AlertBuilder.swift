//
//  AlertBuilder.swift
//  WinDiskWriter
//
//  Created by Macintosh on 28.04.2024.
//

import AppKit

class AlertBuilder {
    private var alert = NSAlert()
    private var responseHandlers: [Int: () -> Void] = [:]

    init(title: String, subtitle: String? = nil, image: NSImage? = nil) {
        alert.messageText = title

        if let subtitle = subtitle {
            alert.informativeText = subtitle
        }

        if let image = image {
            alert.icon = image
        }
    }

    @discardableResult
    func addButton(title: String, preferDefault: Bool = false, handler: (() -> Void)? = nil) -> Self {
        let button = alert.addButton(withTitle: title)

        if preferDefault {
            alert.window.defaultButtonCell = button.cell as? NSButtonCell
        }

        if let handler = handler {
            let uniqueID = button.hashValue

            responseHandlers[uniqueID] = handler
        }

        return self
    }

    func show(in window: NSWindow) {
        alert.beginSheetModal(for: window) { result in
            let buttonIndex = (result.rawValue - NSApplication.ModalResponse.alertFirstButtonReturn.rawValue)

            guard let clickedButton = self.alert.buttons[safe: buttonIndex] else {
                return
            }

            let uniqueID = clickedButton.hashValue
            self.responseHandlers[uniqueID]?()
        }
    }
}
