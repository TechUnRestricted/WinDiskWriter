//
//  OptionsPickerView.swift
//  WinDiskWriter
//
//  Created by Macintosh on 25.12.2024.
//

import SwiftUI

struct OptionsPickerView: View {
    @StateObject private var viewModel: OptionsPickerViewModel
    @StateObject private var directoryMonitor: DirectoryMonitor
    
    private let onImageRemove: () -> Void
    
    init(imageInfo: PickedImageInfo, onImageRemove: @escaping () -> Void) {
        _viewModel = StateObject(
            wrappedValue: OptionsPickerViewModel(imageInfo: imageInfo)
        )
        
        _directoryMonitor = StateObject(
            wrappedValue: DirectoryMonitor(
                url: URL(fileURLWithPath: imageInfo.attachEntity.mountPoint)
            )
        )
        
        self.onImageRemove = onImageRemove
    }
    
    var body: some View {
        contentView
            .onChange(of: directoryMonitor.isDirectoryAccessible) { isDirectoryAvailable in
                if !isDirectoryAvailable {
                    onImageRemove()
                }
            }
            .alert(
                "Disk Erase Required",
                isPresented: $viewModel.isDisplayingEraseWarning,
                actions: {
                    Button("Cancel", role: .cancel) {
                        
                    }
                    
                    Button("Continue", role: .destructive) {
                        
                    }
                },
                message: {
                    Text("To create a bootable drive, the selected disk must be erased. This action cannot be undone.")
                }
            )
            .dialogSeverity(.critical)
    }
    
    private var contentView: some View {
        VStack(alignment: .center, spacing: 0) {
            VStack(alignment: .leading) {
                
                Text("Directory Exists: \(directoryMonitor.isDirectoryAccessible)")
                
                selectedImageView
                selectedDiskView
                selectedFilesystemView
                additionalOptionsView
            }
            .padding([.horizontal, .top])
            .frame(maxWidth: .infinity)
                        
            continueButtonView
        }
    }
    
    private var selectedImageView: some View {
        OptionsPickerSelectedImageView(
            imageInfo: viewModel.imageInfo,
            onRemove: onImageRemove
        )
    }
    
    private var selectedDiskView: some View {
        OptionsPickerDiskPickerView(
            selectedDisk: $viewModel.selectedDisk,
            approximateMinimumSpaceRequired: 1024 * 1024 * 1024
        )
    }
    
    private var selectedFilesystemView: some View {
        OptionsPickerFilesystemView(
            selectedFilesystem: $viewModel.selectedFilesystem
        )
    }
    
    private var additionalOptionsView: some View {
        OptionsPickerOptionsView(
            isInstallLegacyBootSectorEnabled: $viewModel.isInstallLegacyBootSectorEnabled,
            isPatchWindowsInstallerEnabled: $viewModel.isPatchWindowsInstallerEnabled,
            filesystem: viewModel.selectedFilesystem
        )
    }
    
    private var continueButtonView: some View {
        ProminentButton(
            title: "Continue",
            executesOnReturn: true,
            action: {
                viewModel.isDisplayingEraseWarning = true
            }
        )
        .frame(maxHeight: .infinity)
    }
}

#Preview {
    OptionsPickerView(
        imageInfo: PickedImageInfo(
            attachEntity: .mock(),
            imageFileURL: URL(filePath: "/Users/macintosh/WindowsISO/Windows10.iso")
        ),
        onImageRemove: { }
    )
    .frame(maxWidth: .infinity, maxHeight: .infinity)
}
