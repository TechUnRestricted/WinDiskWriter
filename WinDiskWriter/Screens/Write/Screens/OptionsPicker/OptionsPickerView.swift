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
    private let onContinue: (WriteConfiguration) -> Void
    
    init(
        imageInfo: PickedImageInfo,
        onContinue: @escaping (WriteConfiguration) -> Void,
        onImageRemove: @escaping () -> Void
    ) {
        _viewModel = StateObject(
            wrappedValue: OptionsPickerViewModel(imageInfo: imageInfo)
        )
        
        self.onContinue = onContinue
        
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
                errorState: $viewModel.errorState,
                actions: {
                    Button("Discard") {
                        
                    }
                }
            )
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
                viewModel.verifyConfiguration()
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
        ), onContinue: { _ in
            
        },
        onImageRemove: { }
    )
    .frame(maxWidth: .infinity, maxHeight: .infinity)
}
