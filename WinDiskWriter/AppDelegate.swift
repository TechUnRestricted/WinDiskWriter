//
//  AppDelegate.swift
//  WinDiskWriter
//
//  Created by Macintosh on 14.12.2024.
//

import AppKit

class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {    
    func applicationDidFinishLaunching(_ notification: Notification) {
        loadMenu(from: "MainMenu")
    }
    
    private func loadMenu(from nibName: String) {
        guard let nib = NSNib(nibNamed: nibName, bundle: nil) else {
            print("Failed to find nib named \(nibName)")
            return
        }
        
        var topLevelObjects: NSArray? = nil
        guard nib.instantiate(withOwner: nil, topLevelObjects: &topLevelObjects),
              let menu = topLevelObjects?.compactMap({ $0 as? NSMenu }).first else {
            print("Failed to instantiate NSMenu from \(nibName)")
            return
        }
        
        NSApp.mainMenu = menu
    }
}

extension AppDelegate {
    @IBAction func quitApplicationMenuItemAction(_ sender: NSMenuItem) {
        NotificationCenter.default.post(name: .quitApplicationMenuItemSelected, object: nil)
    }
    
    @IBAction func aboutAppMenuItemAction(_ sender: NSMenuItem) {
        NotificationCenter.default.post(name: .aboutAppMenuItemSelected, object: nil)
    }
    
    @IBAction func donateMenuItemAction(_ sender: NSMenuItem) {
        AppHelper.openGitHubPage()
    }
    
    @IBAction func clearApplicationDataMenuItemAction(_ sender: NSMenuItem) {
        NotificationCenter.default.post(name: .clearApplicationDataMenuItemSelected, object: nil)
    }
}
