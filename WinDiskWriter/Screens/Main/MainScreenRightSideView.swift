//
//  MainScreenRightSideView.swift
//  WinDiskWriter
//
//  Created by Macintosh on 14.12.2024.
//

import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect

struct MainScreenRightSideView: View {
    @Binding private var contentScreen: MainContentScreenType
    
    init(contentScreen: Binding<MainContentScreenType>) {
        self._contentScreen = contentScreen
    }
    
    var body: some View {
        contentView
    }
    
    private var contentView: some View {
        tabView
    }
    
    private var tabView: some View {
        TabView(selection: $contentScreen) {
            ForEach(MainContentScreenType.allCases) { screen in
                screen.destination.eraseToAnyView()
                    .tag(screen)
            }
        }
        .introspect(.tabView, on: .macOS(.v11...)) { reference in
            reference.tabViewType = .noTabsNoBorder
        }
    }
}
