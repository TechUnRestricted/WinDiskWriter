//
//  View+MovableByWindowBackground.swift
//  WinDiskWriter
//
//  Created by Macintosh on 12.12.2024.
//

import SwiftUI

private struct MovableByWindowBackground: ViewModifier {
    private let isEnabled: Bool
    
    init(isEnabled: Bool) {
        self.isEnabled = isEnabled
    }
    
    private var windowAccessor: WindowAccessor {
        WindowAccessor { window in
            window?.isMovableByWindowBackground = isEnabled
        }
    }
    
    func body(content: Content) -> some View {
        content
            .background(windowAccessor)
    }
}

extension View {
    func movableByWindowBackground(_ isEnabled: Bool = true) -> some View {
        self.modifier(MovableByWindowBackground(isEnabled: isEnabled))
    }
}
