//
//  ImagePickerScreenView.swift
//  WinDiskWriter
//
//  Created by Macintosh on 22.12.2024.
//

import SwiftUI

struct PickedImageInfo: Equatable {
    let attachEntity: HDIUtilAttachEntity
    let imageFileURL: URL
    
    init(attachEntity: HDIUtilAttachEntity, imageFileURL: URL) {
        self.attachEntity = attachEntity
        self.imageFileURL = imageFileURL
    }
}

struct ImagePickerScreenView: View {
    @StateObject private var viewModel = ImagePickerScreenViewModel()
    
    private let onAttach: (PickedImageInfo) -> Void
    
    init(onAttach: @escaping (PickedImageInfo) -> Void) {
        self.onAttach = onAttach
    }
    
    var body: some View {
        contentView
            .alert(errorState: $viewModel.imageAttachError) {
                Button("Discard") {
                    viewModel.imageFileURL = nil
                }
            }
            .sheet(isPresented: $viewModel.isDisplayingAttachingSheet) {
                LoadingProgressSheetView(title: "Attaching Image...")
            }
    }
    
    private var contentView: some View {
        VStack(alignment: .center, spacing: 24) {
            selectImageAreaView
            
            requiredBottomContainer
        }
        .padding(.top, 15)
        .animation(.snappy, value: viewModel.imageFileURL)
    }
    
    private var selectImageAreaView: some View {
        SelectImageAreaView(droppedFileURL: $viewModel.imageFileURL)
            .frame(maxWidth: 480)
    }
    
    @ViewBuilder
    private var requiredBottomContainer: some View {
        if viewModel.imageFileURL == nil {
            bottomContainerBeforeImagePickedView
        } else {
            bottomContainerAfterImagePickedView
        }
    }
}

// MARK: - Before Image Picked
extension ImagePickerScreenView {
    private var bottomContainerBeforeImagePickedView: some View {
        VStack(alignment: .center, spacing: 10) {
            importantNoticeTextView
            
            supportedWindowsVersionsButton
        }
    }
    
    private var importantNoticeTextView: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("IMPORTANT: Make sure that you're choosing a supported image type.")
            Text("You can get detailed information by clicking the button below.")
        }
        .lineLimit(1, reservesSpace: true)
        .fontWeight(.thin)
        .opacity(0.35)
    }
    
    private var supportedWindowsVersionsButton: some View {
        TexturedRoundedButton("View Supported Windows Images") {
            viewModel.isDisplayingSupportedImagesSheet = true
        }
        .fixedSize()
        .sheet(isPresented: $viewModel.isDisplayingSupportedImagesSheet) {
            SupportedImagesView()
                .frame(width: 640, height: 390)
        }
    }
}

// MARK: - After Image Picked
extension ImagePickerScreenView {
    private var bottomContainerAfterImagePickedView: some View {
        ProminentButton(
            title: "Continue",
            executesOnReturn: false,
            action: {
                Task {
                    guard let attachEntity = await viewModel.attachImage(),
                          let imageFileURL = viewModel.imageFileURL else {
                        return
                    }
                
                    let result = PickedImageInfo(
                        attachEntity: attachEntity,
                        imageFileURL: imageFileURL
                    )
                
                    await MainActor.run {
                        onAttach(result)
                    }
                }
            }
        )
    }
}
