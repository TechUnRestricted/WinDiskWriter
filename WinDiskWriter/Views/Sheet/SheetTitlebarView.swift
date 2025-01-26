//
//  SheetTitlebarView.swift
//  WinDiskWriter
//
//  Created by Macintosh on 21.12.2024.
//

import SwiftUI

enum SheetTitlebarCloseButtonState {
    case enabled
    case disabled
    case hidden
}

struct SheetTitlebarView: View {
    @Environment(\.dismiss) private var dismiss
    
    private let title: String
    private let closeButtonState: SheetTitlebarCloseButtonState
    
    init(title: LocalizedStringResource, closeButtonState: SheetTitlebarCloseButtonState = .enabled) {
        self.title = title.stringValue
        self.closeButtonState = closeButtonState
    }
    
    @_disfavoredOverload
    init(title: String, closeButtonState: SheetTitlebarCloseButtonState = .enabled) {
        self.title = title
        self.closeButtonState = closeButtonState
    }
    
    var body: some View {
        horizontalContainerView
            .background(BackdropBlurVisualEffectView(blendingMode: .withinWindow))
    }
    
    private var horizontalContainerView: some View {
        HStack(alignment: .center, spacing: 8) {
            Spacer()
                .overlay(alignment: .leading) {
                    dismissButtonView
                }
            
            titleView
            
            Spacer()
        }
        .frame(height: GlobalConstants.defaultSheetTitlebarHeight)
        .opacity(0.8)
    }
    
    private var titleView: some View {
        Text(title)
            .lineLimit(1, reservesSpace: true)
    }
    
    private var dismissButtonView: some View {
        Button(action: {
            dismiss()
        }, label: {
            dismissImageView
        })
        .buttonStyle(.plain)
        .padding(.leading, GlobalConstants.defaultSheetTitlebarHeight / 6)
        .opacity(0.8)
    }
    
    private var dismissImageView: some View {
        Image(systemName: "xmark")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .padding(GlobalConstants.defaultSheetTitlebarHeight / 3)
            .frame(width: GlobalConstants.defaultSheetTitlebarHeight, height: GlobalConstants.defaultSheetTitlebarHeight)
            .contentShape(Rectangle())
    }
}

#Preview {
    SheetTitlebarView(
        title: "Supported Images",
        closeButtonState: .enabled
    )
}
