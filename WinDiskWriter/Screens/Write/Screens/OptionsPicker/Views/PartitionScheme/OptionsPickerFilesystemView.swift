//
//  OptionsPickerFilesystemView.swift
//  WinDiskWriter
//
//  Created by Macintosh on 28.12.2024.
//

import SwiftUI

struct OptionsPickerFilesystemView: View {
    @Binding private var selectedFilesystem: Filesystem
    
    init(selectedFilesystem: Binding<Filesystem>) {
        _selectedFilesystem = selectedFilesystem
    }
    
    var body: some View {
        contentView
    }
    
    private var contentView: some View {
        OptionsPickerContainerView(title: "File System") {
            pickerView
        }
    }
    
    private var pickerView: some View {
        PickerView(
            orientation: .horizontal,
            items: Filesystem.allCases,
            selectedItem: $selectedFilesystem
        )
    }
    
    /*
    private var helpButtonView: some View {
        HelpButtonView(
            text: "FAT32 is recommended for better compatibility with most PCs and works seamlessly with all boot modes. However, exFAT is more suitable for use with Intel-based Macs due to its optimized performance in that environment."
        )
    }
     */
}

#Preview {
    OptionsPickerFilesystemView(selectedFilesystem: .constant(.FAT32))
}


