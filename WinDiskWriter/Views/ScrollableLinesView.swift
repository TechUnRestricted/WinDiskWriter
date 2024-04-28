//
//  ScrollableLinesView.swift
//  WinDiskWriter
//
//  Created by Macintosh on 23.04.2024.
//

import Cocoa

class ScrollableLinesView: NSScrollView {
    private enum Constants {
        static let tableViewAdditionalHeight: CGFloat = 12

        static let tableColumnIdentifier: String = "Column"
        static let cornerRadius: CGFloat = 10.0
        static let borderColor: NSColor = .textColor.withAlphaComponent(0.25)
        static let borderWidth: CGFloat = 1.5

        static let yAxisPadding: CGFloat = 4.0
    }

    override var allowsVibrancy: Bool {
        return true
    }

    var isAutoScrollEnabled: Bool = true

    private var tableView = NSTableView()
    private var items: [String] = []

    private let itemIdentifier = NSUserInterfaceItemIdentifier(rawValue: Constants.tableColumnIdentifier)
    private lazy var mainColumn = NSTableColumn(identifier: itemIdentifier)

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func appendRow(withContent content: String) {
        items.append(content)

        let lastItemIndex = items.count - 1

        let indexSet = IndexSet(integer: lastItemIndex)
        
        tableView.beginUpdates()

        tableView.insertRows(at: indexSet)
        updateColumnWidth(forIndexSet: indexSet)

        tableView.endUpdates()

        if isAutoScrollEnabled {
            tableView.scrollRowToVisible(lastItemIndex)
        }
    }

    private func setupViews() {
        setupSelf()
        setupTableView()
    }

    private func updateColumnWidth(forIndexSet indexSet: IndexSet) {
        for index in indexSet {
            guard let string = items[safe: index] else {
                continue
            }

            let temporaryCell = VerticallyCenteredTextFieldCell(textCell: string)
            let cellWidth = temporaryCell.cellSize.width
            let columnWidth = mainColumn.width

            if cellWidth > columnWidth {
                mainColumn.width = cellWidth
                mainColumn.minWidth = cellWidth
                tableView.frame.size.width = cellWidth
            }
        }
    }
}

extension ScrollableLinesView {
    private func setupSelf() {
        // Give the NSScrollView a backing layer and set it's corner radius.
        wantsLayer = true
        layer?.cornerRadius = Constants.cornerRadius

        // Give the NSScrollView's internal clip view a backing layer and set it's corner radius.
        contentView.wantsLayer = true

        automaticallyAdjustsContentInsets = false

        contentInsets.top = Constants.yAxisPadding
        contentInsets.bottom = Constants.yAxisPadding

        if let contentViewLayer = contentView.layer {
            contentViewLayer.cornerRadius = Constants.cornerRadius
            contentViewLayer.borderColor = Constants.borderColor.cgColor
            contentViewLayer.borderWidth = Constants.borderWidth
        }
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self

        tableView.addTableColumn(mainColumn)

        tableView.headerView = nil
        tableView.allowsMultipleSelection = true
        tableView.focusRingType = .none

        documentView = tableView
        hasVerticalScroller = true
        hasHorizontalScroller = true

        if #available(macOS 11.0, *) {
            tableView.style = .fullWidth
        }

        tableView.rowHeight = VerticallyCenteredTextFieldCell.usedFont.capHeight + Constants.tableViewAdditionalHeight
    }
}

// MARK: - NSTableViewDataSource
extension ScrollableLinesView: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return items.count
    }

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return items[safe: row]
    }
}

extension ScrollableLinesView: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, dataCellFor tableColumn: NSTableColumn?, row: Int) -> NSCell? {
        return VerticallyCenteredTextFieldCell()
    }
}
