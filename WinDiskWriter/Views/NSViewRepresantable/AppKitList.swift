//
//  AppKitList.swift
//  WinDiskWriter
//
//  Created by Macintosh on 14.12.2024.
//

import SwiftUI

struct AppKitList<Data, RowContent>: NSViewRepresentable where Data: RandomAccessCollection & Equatable, Data.Element: Identifiable, RowContent: View {
    typealias NSViewType = NSTableView
    
    private var data: Data
    private var selection: Binding<Data.Element?>
    private var rowContent: (Data.Element) -> RowContent
    
    init(
        _ data: Data,
        selection: Binding<Data.Element?>,
        @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent
    ) {
        self.data = data
        self.selection = selection
        self.rowContent = rowContent
    }
    
    init(
        _ data: Data,
        selection: Binding<Data.Element>,
        @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent
    ) {
        self.data = data
        self.selection = Binding(
            get: { selection.wrappedValue },
            set: { selection.wrappedValue = $0 ?? selection.wrappedValue }
        )
        self.rowContent = rowContent
    }
    
    func makeNSView(context: Context) -> NSTableView {
        let tableView = NSTableView()
        tableView.headerView = nil
        tableView.addTableColumn(NSTableColumn(identifier: NSUserInterfaceItemIdentifier("Column")))
        tableView.delegate = context.coordinator
        tableView.dataSource = context.coordinator
        tableView.allowsMultipleSelection = false
        tableView.focusRingType = .none
        tableView.allowsColumnResizing = false
        tableView.columnAutoresizingStyle = .uniformColumnAutoresizingStyle
        
        context.coordinator.tableView = tableView
        
        return tableView
    }
    
    func updateNSView(_ nsView: NSTableView, context: Context) {
        if context.coordinator.data != data {
            context.coordinator.data = data
            nsView.reloadData()
        }
        
        // Restore selection
        if let selectedItem = selection.wrappedValue {
            if let rowIndex = data.firstIndex(where: { $0.id == selectedItem.id }) {
                let row = data.distance(from: data.startIndex, to: rowIndex)
                nsView.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
                nsView.scrollRowToVisible(row)
            }
        } else {
            nsView.selectRowIndexes(IndexSet(), byExtendingSelection: false)
        }
        
        nsView.sizeLastColumnToFit()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(data: data, selection: selection, rowContent: rowContent)
    }
    
    // MARK: - Coordinator
    class Coordinator: NSObject, NSTableViewDelegate, NSTableViewDataSource {
        var data: Data
        
        private var selection: Binding<Data.Element?>
        private var rowContent: (Data.Element) -> RowContent
        weak var tableView: NSTableView?
        
        // Cache for NSHostingViews to avoid recreating them
        private var hostingViews: [Data.Element.ID: NSHostingView<RowContent>] = [:]
        
        init(data: Data, selection: Binding<Data.Element?>, rowContent: @escaping (Data.Element) -> RowContent) {
            self.data = data
            self.selection = selection
            self.rowContent = rowContent
        }
        
        func numberOfRows(in tableView: NSTableView) -> Int {
            return data.count
        }
        
        func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
            let item = data[data.index(data.startIndex, offsetBy: row)]
            
            if let cachedView = hostingViews[item.id] {
                return cachedView
            }
            
            let hostingView = NSHostingView(rootView: rowContent(item))
            hostingView.translatesAutoresizingMaskIntoConstraints = false
            hostingViews[item.id] = hostingView
            
            return hostingView
        }
        
        func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
            let item = data[data.index(data.startIndex, offsetBy: row)]
            
            // Reuse cached hosting view if available
            if let cachedView = hostingViews[item.id] {
                return cachedView.fittingSize.height
            }
            
            let hostingView = NSHostingView(rootView: rowContent(item))
            hostingView.translatesAutoresizingMaskIntoConstraints = false
            hostingViews[item.id] = hostingView
            
            return hostingView.fittingSize.height
        }
        
        func tableViewSelectionDidChange(_ notification: Notification) {
            guard let tableView = notification.object as? NSTableView else { return }
            let selectedRow = tableView.selectedRow
            
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                
                if selectedRow >= 0, selectedRow < data.count {
                    if let selectedItem = data[safe: data.index(data.startIndex, offsetBy: selectedRow)] {
                        self.selection.wrappedValue = selectedItem
                    } else {
                        self.selection.wrappedValue = nil
                    }
                } else {
                    self.selection.wrappedValue = nil
                }
            }
        }
    }
}
