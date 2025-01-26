//
//  WindowAccessor.swift
//  WinDiskWriter
//
//  Created by Macintosh on 12.12.2024.
//

import SwiftUI

struct WindowAccessor: NSViewRepresentable {
    private let configure: (NSWindow?) -> Void

    init(configure: @escaping (NSWindow?) -> Void) {
        self.configure = configure
    }
    
    func makeNSView(context: Context) -> NSView {
        let view = NSView()

        DispatchQueue.main.async {
            if let window = view.window {
                configure(window)
            }
        }

        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async {
            if let window = nsView.window {
                configure(window)
            }
        }
    }
}
