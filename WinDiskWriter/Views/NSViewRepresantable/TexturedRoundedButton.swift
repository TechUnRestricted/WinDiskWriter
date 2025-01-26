//
//  TexturedRoundedButton.swift
//  WinDiskWriter
//
//  Created by Macintosh on 13.12.2024.
//

import SwiftUI
import AppKit

struct TexturedRoundedButton: NSViewRepresentable {
    private let title: String
    private let action: () -> Void

    init(_ titleKey: LocalizedStringResource, action: @escaping () -> Void) {
        self.title = titleKey.stringValue
        self.action = action
    }
    
    @_disfavoredOverload
    init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
    
    func makeNSView(context: Context) -> NSButton {
        let button = NSButton()
        button.bezelStyle = .texturedRounded
        button.title = title
        button.target = context.coordinator
        button.action = #selector(Coordinator.buttonClicked)
        
        return button
    }

    func updateNSView(_ nsView: NSButton, context: Context) {
        nsView.title = title
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(action: action)
    }

    class Coordinator: NSObject {
        private let action: () -> Void

        init(action: @escaping () -> Void) {
            self.action = action
        }

        @objc func buttonClicked() {
            action()
        }
    }
}

#Preview {
    TexturedRoundedButton("Source Code") {
        
    }
    .fixedSize()
    .padding()
}
