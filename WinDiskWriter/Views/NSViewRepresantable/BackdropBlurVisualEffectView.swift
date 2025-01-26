//
//  BackdropBlurVisualEffectView.swift
//  WinDiskWriter
//
//  Created by Macintosh on 12.12.2024.
//

import SwiftUI

private struct BackdropBlurVisualEffectBridge: NSViewRepresentable {
    private let blendingMode: NSVisualEffectView.BlendingMode
    
    init(blendingMode: NSVisualEffectView.BlendingMode) {
        self.blendingMode = blendingMode
    }
    
    func makeNSView(context: Context) -> NSView {
        let view = NSVisualEffectView()
        view.state = .active
        view.blendingMode = blendingMode
        
        return view
    }
    
    func updateNSView(_ view: NSView, context: Context) {
        
    }
}

struct BackdropBlurVisualEffectView: View {
    private let blendingMode: NSVisualEffectView.BlendingMode
    
    init(blendingMode: NSVisualEffectView.BlendingMode = .behindWindow) {
        self.blendingMode = blendingMode
    }
    
    var body: some View {
        BackdropBlurVisualEffectBridge(blendingMode: blendingMode)
            .ignoresSafeArea(.all)
    }
}
