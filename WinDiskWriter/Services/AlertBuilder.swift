//
//  AlertBuilder.swift
//  WinDiskWriter
//
//  Created by Macintosh on 28.04.2024.
//

import AppKit

class AlertBuilder {
    private var alert = NSAlert()
    private var responseHandlers: [NSApplication.ModalResponse: () -> Void] = [:]

    @discardableResult
    func addButton(title: String, prefareDefault: Bool = false, handler: (() -> Void)? = nil) -> Self {
        let button = alert.addButton(withTitle: title)

        if prefareDefault {
            alert.window.defaultButtonCell = button.cell as? NSButtonCell
        }

        if let handler = handler {
            let response = NSApplication.ModalResponse(alert.buttons.count)
            responseHandlers[response] = handler
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

    func show(in window: NSWindow) {
        alert.beginSheetModal(for: window) { [weak self] response in
            self?.responseHandlers[response]?()
        }
    }
}
