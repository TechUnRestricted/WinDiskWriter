//
//  SupportedImagesView.swift
//  WinDiskWriter
//
//  Created by Macintosh on 21.12.2024.
//

import SwiftUI

struct SupportedImagesView: View {
    var body: some View {
        contentView
            .background(BackdropBlurVisualEffectView(blendingMode: .behindWindow))
            .safeAreaInset(edge: .top) {
                SheetTitlebarView(title: "Supported Images")
            }
    }
    
    private var contentView: some View {
        listView
    }
    
    private var listView: some View {
        List(ImageSupportInfo.createList()) { infoItem in
            SupportedImageListEntryView(imageSupportInfo: infoItem)
                .listRowSeparator(.hidden)
                .scaleEffect()
        }
        .applyListSheetStyling()
    }
}

#Preview {
    SupportedImagesView()
}
