//
//  SwitchPickerView.swift
//  WinDiskWriter
//
//  Created by Macintosh on 22.04.2024.
//

import AppKit

class SwitchPickerView<T: RawRepresentable & Hashable>: NSSegmentedControl where T.RawValue == Int {
    typealias SelectionHandler = (T) -> Void

    var selectedCase: T? {
        guard segmentCount > 0 else {
            return nil
        }
        
        return T(rawValue: selectedSegment)
    }

    private var selectionHandlers: [T: SelectionHandler] = [:]

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        target = self
        action = #selector(segmentChanged(_:))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func addSegment(title: String, identifier: T, makeDefault: Bool = false, handler: SelectionHandler? = nil) {
        let index = segmentCount
        segmentCount += 1

        setLabel(title, forSegment: index)

        if let handler = handler {
            selectionHandlers[identifier] = handler
        }

        if makeDefault {
            setSelected(true, forSegment: index)
        }
    }

    func removeAllSegments() {
        segmentCount = 0
        selectionHandlers.removeAll()
    }

    @objc private func segmentChanged(_ sender: NSSegmentedControl) {
        if let selectedValue = T(rawValue: selectedSegment) {
            selectionHandlers[selectedValue]?(selectedValue)
        }
    }

    @objc private func menuItemSelected(_ sender: NSMenuItem) {
        if let identifier = sender.representedObject as? T {
            selectionHandlers[identifier]?(identifier)
        }
    }
}
