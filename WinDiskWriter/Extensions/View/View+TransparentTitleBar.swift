//
//  View+TransparentTitleBar.swift
//  WinDiskWriter
//
//  Created by Macintosh on 12.12.2024.
//

import SwiftUI

private struct TransparentTitleBar: ViewModifier {
    private let isEnabled: Bool
    
    init(isEnabled: Bool) {
        self.isEnabled = isEnabled
    }
    
    private var windowAccessor: WindowAccessor {
        WindowAccessor { window in
            window?.titlebarAppearsTransparent = isEnabled
        }
    }
    
    func body(content: Content) -> some View {
        content
            .background(windowAccessor)
    }
}

extension View {
    func transparentTitleBar(_ isEnabled: Bool = true) -> some View {
        self.modifier(TransparentTitleBar(isEnabled: isEnabled))
    }
}
