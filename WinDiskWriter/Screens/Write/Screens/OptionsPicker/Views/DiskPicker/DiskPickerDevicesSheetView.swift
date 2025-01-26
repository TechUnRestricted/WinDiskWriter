//
//  DiskPickerDevicesSheetView.swift
//  WinDiskWriter
//
//  Created by Macintosh on 30.12.2024.
//

import SwiftUI

struct DiskPickerDevicesSheetView: View {
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject private var diskMonitor: DiskMonitor
    
    @State private var selectedDisk: DiskInfo?
    private let approximateMinimumSpaceRequired: UInt64
    private let onPick: (DiskInfo) -> Void
    
    private var isChooseButtonAvailable: Bool {
        guard let selectedDisk else {
            return false
        }
        
        let diskSize: UInt64 = (selectedDisk.media.size ?? 0)
        
        return diskSize >= approximateMinimumSpaceRequired
    }
    
    private var filteredDisks: [DiskInfo] {
        diskMonitor.disks.filter { diskInfo in
            guard let isWhole = diskInfo.media.isWhole else {
                print("[\(Date())] Disk filtered out: Missing isWhole property")
                return false
            }
            
            guard let isRemovable = diskInfo.media.isRemovable else {
                print("[\(Date())] Disk filtered out: Missing isRemovable property")
                return false
            }
            
            guard let isEjectable = diskInfo.media.isEjectable else {
                print("[\(Date())] Disk filtered out: Missing isEjectable property")
                return false
            }
            
            guard let isExternal = diskInfo.device.isInternal?.flipped else {
                print("[\(Date())] Disk filtered out: Missing isInternal property")
                return false
            }
            
            let deviceProtocolMatches = (diskInfo.device.protocol ?? "")
                .uppercased()
                .stripped()
                .hasPrefix("USB")
            
            return isWhole && isRemovable && isEjectable && (isExternal || deviceProtocolMatches)
        }
    }
    
    init(
        diskMonitor: DiskMonitor,
        selectedDisk: DiskInfo?,
        approximateMinimumSpaceRequired: UInt64,
        onPick: @escaping (DiskInfo) -> Void
    ) {
        self.diskMonitor = diskMonitor
        self._selectedDisk = State(wrappedValue: selectedDisk)
        self.approximateMinimumSpaceRequired = approximateMinimumSpaceRequired
        self.onPick = onPick
    }
    
    var body: some View {
        contentView
            .frame(width: 500, height: 400)
            .background(BackdropBlurVisualEffectView(blendingMode: .behindWindow))
            .safeAreaInset(edge: .top) {
                titleBarView
            }
            .safeAreaInset(edge: .bottom) {
                bottomBarView
            }
            .onChange(of: filteredDisks) { filteredDisks in
                guard let selectedDisk else { return }
                
                if !filteredDisks.contains(selectedDisk) {
                    self.selectedDisk = nil
                }
            }
    }
    
    private var titleBarView: some View {
        SheetTitlebarView(
            title: "Choose the destination device",
            closeButtonState: .enabled
        )
    }
    
    private var contentView: some View {
        listView
    }
    
    private var listView: some View {
        List(filteredDisks, selection: $selectedDisk) { disk in
            createEntry(for: disk)
                .tag(disk)
        }
        .applyListSheetStyling()
    }

    private func createEntry(for diskInfo: DiskInfo) -> some View {
        PickableDiskInfoView(
            diskInfo: diskInfo,
            approximateMinimumSpaceRequired: approximateMinimumSpaceRequired
        )
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
    }
    
    private var bottomBarView: some View {
        HStack {
            Spacer()
            
            ProminentButton(
                title: "Choose",
                executesOnReturn: true,
                action: {
                    if let selectedDisk {
                        onPick(selectedDisk)
                    }
                    
                    dismiss()
                }
            )
            .disabled(!isChooseButtonAvailable)
            
            Spacer()
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(BackdropBlurVisualEffectView(blendingMode: .withinWindow))
    }
    
}

#Preview {
    DiskPickerDevicesSheetView(
        diskMonitor: DiskMonitor(),
        selectedDisk: nil,
        approximateMinimumSpaceRequired: 1024 * 1024 * 1024 * 1024,
        onPick: { _ in
            
        }
    )
}
