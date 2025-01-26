//
//  OptionsPickerDiskPickerView.swift
//  WinDiskWriter
//
//  Created by Macintosh on 29.12.2024.
//

import SwiftUI

struct OptionsPickerDiskPickerView: View {
    @StateObject private var diskMonitor = DiskMonitor()
    @Binding private var selectedDisk: DiskInfo?
    
    @State private var isDiskPickerPresented: Bool = false
    
    private let approximateMinimumSpaceRequired: UInt64

    init(
        selectedDisk: Binding<DiskInfo?>,
        approximateMinimumSpaceRequired: UInt64
    ) {
        _selectedDisk = selectedDisk
        self.approximateMinimumSpaceRequired = approximateMinimumSpaceRequired
    }
    
    var body: some View {
        contentView
            .onChange(of: diskMonitor.disks) { disksList in
                guard let selectedDisk else { return }
                
                if !disksList.contains(selectedDisk) {
                    self.selectedDisk = nil
                }
            }
            .animation(.snappy, value: selectedDisk)
            .sheet(isPresented: $isDiskPickerPresented) {
                diskPickerSheetView
            }
    }
    
    private var contentView: some View {
        HStack(alignment: .center) {
            VStack(alignment: .center) {
                if let selectedDisk {
                    PickableDiskInfoView(
                        diskInfo: selectedDisk,
                        approximateMinimumSpaceRequired: approximateMinimumSpaceRequired
                    )
                } else {
                    DiskPickerNoDiskSelectedView()
                }
            }
            .frame(height: 32)
            
            openDropdownImageView
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(minHeight: 60)
        .background(.gray.opacity(0.1))
        .contentShape(.rect)
        .wrapToButton {
            isDiskPickerPresented = true
        }
        .bordered(cornerRadius: 16, color: .gray.opacity(0.25), lineWidth: 1)
    }
    
    private var openDropdownImageView: some View {
        Image(systemName: "chevron.down")
            .padding(6)
    }
    
    private var diskPickerSheetView: some View {
        DiskPickerDevicesSheetView(
            diskMonitor: diskMonitor,
            selectedDisk: selectedDisk,
            approximateMinimumSpaceRequired: approximateMinimumSpaceRequired,
            onPick: { selectedDisk in
                self.selectedDisk = selectedDisk
            }
        )
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State var selectedDisk: DiskInfo? = .mock()
        
        var body: some View {
            OptionsPickerDiskPickerView(
                selectedDisk: $selectedDisk,
                approximateMinimumSpaceRequired: 1024 * 1024 * 1024
            )
            .padding(44)
        }
    }
    
    return PreviewWrapper()
}
