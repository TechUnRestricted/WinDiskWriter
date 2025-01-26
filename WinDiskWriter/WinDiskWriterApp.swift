//
//  WinDiskWriterApp.swift
//  WinDiskWriter
//
//  Created by Macintosh on 12.12.2024.
//

import SwiftUI

@main
struct WinDiskWriterApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @State private var shouldDisplayWelcomePopover: Bool = !AppHelper.launchedBefore()
    
    var body: some Scene {
        Window("WinDiskWriter", id: "Main Window") {
            MainScreenView()
                .frame(width: 960, height: 460)
                .onNotification(.aboutAppMenuItemSelected) {
                    shouldDisplayWelcomePopover = true
                }
                .onNotification(.quitApplicationMenuItemSelected) {
                    NSApp.terminate(self)
                }
                .sheet(isPresented: $shouldDisplayWelcomePopover) {
                    WelcomeScreenView()
                }
                .toolbar {
                    Color.clear
                }
                .movableByWindowBackground()
                .configureWindowButtons(isMaximizeEnabled: false)
        }
        .windowResizability(.contentSize)
    }
}
