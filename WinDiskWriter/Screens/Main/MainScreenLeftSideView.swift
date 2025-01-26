//
//  MainScreenLeftSideView.swift
//  WinDiskWriter
//
//  Created by Macintosh on 14.12.2024.
//

import SwiftUI

struct MainScreenLeftSideView: View {
    @Binding private var contentScreen: MainContentScreenType
    
    init(contentScreen: Binding<MainContentScreenType>) {
        self._contentScreen = contentScreen
    }
    
    var body: some View {
        contentView
    }
    
    private var contentView: some View {
        VStack(alignment: .center, spacing: 12) {
            topAppInfo
            
            listView
            
            Spacer()
            
            appVersionView
        }
    }
    
    private var topAppInfo: some View {
        VStack(alignment: .center) {
            Image.appIcon
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
            
            Text("WinDiskWriter")
                .fontWeight(.thin)
                .lineLimit(1, reservesSpace: true)
                .font(.title2)
        }
    }
    
    private var listView: some View {
        AppKitList(MainContentScreenType.allCases, selection: $contentScreen) { screen in
            createSidebarItem(for: screen)
        }
    }
        
    private func createSidebarItem(for screen: MainContentScreenType) -> some View {
        let isDonationsScreen = screen == .donations
        
        return HStack(alignment: .center, spacing: 12) {
            Image(systemName: screen.iconSystemName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 18)
                .fontWeight(.medium)
            
            Text(screen.shortTitle)
            
            Spacer()
        }
        .padding(6)
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .modifier(PulsatingEffect(apply: isDonationsScreen))
    }
    
    private var appVersionView: some View {
        Text(Bundle.main.releaseWithBuildVersionHumanReadableString)
            .lineLimit(1)
            .opacity(0.35)
            .padding(4)
            .padding(.bottom, 12)
    }
}
