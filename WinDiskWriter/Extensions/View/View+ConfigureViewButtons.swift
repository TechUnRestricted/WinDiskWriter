//
//  View+ConfigureViewButtons.swift
//  WinDiskWriter
//
//  Created by Macintosh on 12.12.2024.
//

import SwiftUI

private struct ConfigureWindowButtons: ViewModifier {
    private let isCloseEnabled: Bool?
    private let isMinimizeEnabled: Bool?
    private let isMaximizeEnabled: Bool?
    
    init(isCloseEnabled: Bool?, isMinimizeEnabled: Bool?, isMaximizeEnabled: Bool?) {
        self.isCloseEnabled = isCloseEnabled
        self.isMinimizeEnabled = isMinimizeEnabled
        self.isMaximizeEnabled = isMaximizeEnabled
    }
    
    private var windowAccessor: WindowAccessor {
        WindowAccessor { window in
            if let isCloseEnabled {
                window?.standardWindowButton(NSWindow.ButtonType.closeButton)?.isEnabled = isCloseEnabled
            }
            
            if let isMinimizeEnabled {
                window?.standardWindowButton(NSWindow.ButtonType.miniaturizeButton)?.isEnabled = isMinimizeEnabled
            }
            
            if let isMaximizeEnabled {
                window?.standardWindowButton(NSWindow.ButtonType.zoomButton)?.isEnabled = isMaximizeEnabled
            }
        }
    }
    
    func body(content: Content) -> some View {
        content
            .background(windowAccessor)
    }
}

extension View {
    func configureWindowButtons(
        isCloseEnabled: Bool? = nil,
        isMinimizeEnabled: Bool? = nil,
        isMaximizeEnabled: Bool? = nil
    ) -> some View {
        self.modifier(
            ConfigureWindowButtons(
                isCloseEnabled: isCloseEnabled,
                isMinimizeEnabled: isMinimizeEnabled,
                isMaximizeEnabled: isMaximizeEnabled
            )
        )
    }
}
