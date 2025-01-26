//
//  AppKitSplitView.swift
//  WinDiskWriter
//
//  Created by Macintosh on 15.12.2024.
//


import SwiftUI
import AppKit

struct AppKitSplitView<Sidebar: View, Detail: View>: NSViewControllerRepresentable {
    // Private properties
    private let sidebar: Sidebar
    private let detail: Detail

    private let minimumThickness: CGFloat
    private let maximumThickness: CGFloat
    
    // Initializer
    init(
        sidebar: Sidebar,
        detail: Detail,
        minimumThickness: CGFloat = 260,
        maximumThickness: CGFloat = 260
    ) {
        self.sidebar = sidebar
        self.detail = detail
        self.minimumThickness = minimumThickness
        self.maximumThickness = maximumThickness
    }

    func makeNSViewController(context: Context) -> NSSplitViewController {
        let splitViewController = NSSplitViewController()

        // Sidebar
        let sidebarController = NSHostingController(rootView: sidebar)
        let sidebarItem = NSSplitViewItem(sidebarWithViewController: sidebarController)
        sidebarItem.minimumThickness = minimumThickness
        sidebarItem.maximumThickness = maximumThickness
        sidebarItem.canCollapseFromWindowResize = false
        sidebarItem.canCollapse = false
    
        // Detail View
        let detailController = NSHostingController(rootView: detail)
        let detailItem = NSSplitViewItem(viewController: detailController)
        detailItem.canCollapse = false

        // Add items to split view controller
        splitViewController.addSplitViewItem(sidebarItem)
        splitViewController.addSplitViewItem(detailItem)

        return splitViewController
    }

    func updateNSViewController(_ nsViewController: NSSplitViewController, context: Context) {
        // SwiftUI will handle updates
    }
}
