//
//  MainScreenView.swift
//  WinDiskWriter
//
//  Created by Macintosh on 14.12.2024.
//

import SwiftUI

struct MainScreenView: View {
    @State private var contentScreen: MainContentScreenType = .about
    
    init() {

    }
    
    var body: some View {
        contentView
            .navigationTitle(contentScreen.regularTitle)
            //.navigationSubtitle(contentScreen.subtitle)
            //.configureWindowButtons(isCloseEnabled: false)
    }
    
    private var contentView: some View {
        navigationSplitView
    }
    
    private var navigationSplitView: some View {
        AppKitSplitView(
            sidebar: MainScreenLeftSideView(contentScreen: $contentScreen),
            detail: MainScreenRightSideView(contentScreen: $contentScreen)
        )
        .ignoresSafeArea()
    }
}

#Preview {
    MainScreenView()
}
