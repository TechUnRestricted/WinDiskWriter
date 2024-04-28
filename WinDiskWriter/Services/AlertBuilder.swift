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

    @discardableResult
    func addButton(title: String, preferDefault: Bool = false, handler: (() -> Void)? = nil) -> Self {
        let button = alert.addButton(withTitle: title)

        if preferDefault {
            alert.window.defaultButtonCell = button.cell as? NSButtonCell
        }

        if let handler = handler {
            let uniqueTag = alert.buttons.count - 1

            responseHandlers[uniqueTag] = handler
        }

        return self
    }

    @discardableResult
    func setMessage(text: String) -> Self {
        alert.messageText = text

        return self
    }

    @discardableResult
    func setInformative(text: String) -> Self {
        alert.informativeText = text

        return self
    }

    @discardableResult
    func setImage(_ image: NSImage) -> Self {
        alert.icon = image
        
        return self
    }

    func show(in window: NSWindow) {
        alert.beginSheetModal(for: window) { result in
            let buttonKey = NSApplication.ModalResponse.alertFirstButtonReturn.rawValue - result.rawValue
            self.responseHandlers[buttonKey]?()
        }
    }
}
