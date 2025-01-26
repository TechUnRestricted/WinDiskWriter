//
//  ProminentButton.swift
//  WinDiskWriter
//
//  Created by Macintosh on 22.12.2024.
//

import SwiftUI

struct ProminentButton: View {
    private let title: String
    private let executesOnReturn: Bool
    private let action: () -> Void
    
    init(title: LocalizedStringResource, executesOnReturn: Bool, action: @escaping () -> Void) {
        self.title = title.stringValue
        self.executesOnReturn = executesOnReturn
        self.action = action
    }
    
    @_disfavoredOverload
    init(title: String, executesOnReturn: Bool, action: @escaping () -> Void) {
        self.title = title
        self.executesOnReturn = executesOnReturn
        self.action = action
    }
    
    var body: some View {
        contentView
    }
    
    private var contentView: some View {
        Button(
            action: action,
            label: {
                textView
            }
        )
        .buttonStyle(BorderedProminentButtonStyle())
        .if(executesOnReturn) {
            if #available(macOS 14.0, *) {
                $0.focusable()
                    .focusEffectDisabled()
                    .onKeyPress(.return) {
                        action()
                        return .handled
                    }
                    .eraseToAnyView()
            } else {
                $0.eraseToAnyView()
            }
        }
    }
    
    private var textView: some View {
        Text(title)
            .fontWeight(.medium)
            .frame(minWidth: 228, minHeight: 28)
    }
}
