//
//  OptionsPickerSelectedImageView.swift
//  WinDiskWriter
//
//  Created by Macintosh on 25.12.2024.
//

import SwiftUI

struct OptionsPickerSelectedImageView: View {
    @StateObject private var viewModel: OptionsPickerSelectedImageViewModel
    
    private let onRemove: () -> Void
    
    init(imageInfo: PickedImageInfo, onRemove: @escaping () -> Void) {
        _viewModel = StateObject(
            wrappedValue: OptionsPickerSelectedImageViewModel(imageInfo: imageInfo)
        )
        
        self.onRemove = onRemove
    }
    
    var body: some View {
        containerView
    }
    
    /*
    private var titleView: some View {
        Text("Selected Image")
            .font(.title3)
            .fontWeight(.medium)
    }
    
    private var contentView: some View {
        OptionsPickerContainerView(
            title: "Selected Image",
            content: {
                containerView
            }
        )
    }
     */
    
    private var containerView: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(nsImage: viewModel.fileIcon)
            
            VStack(alignment: .leading) {
                Text(viewModel.directoryName)
                    .font(.headline)
                
                Text(viewModel.mountPointLastComponent)
                    .font(.subheadline)
                    .opacity(0.5)
            }
            .lineLimit(1, reservesSpace: true)
            
            Spacer()
            
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .padding(8)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.gray.opacity(0.1))
        .bordered(cornerRadius: 16, color: .gray.opacity(0.25))
    }

        
    private var volumeInfoContainerView: some View {
        VStack(alignment: .leading) {
            Text(viewModel.directoryName)
                .font(.headline)
            
            Text(viewModel.mountPointLastComponent)
                .font(.subheadline)
                .opacity(0.5)
        }
        .lineLimit(1, reservesSpace: true)
    }
    
    private var removeButtonView: some View {
        Button(action: onRemove, label: {
            Image(systemName: "xmark")
                .padding(8)
                .contentShape(.rect)
        })
        .buttonStyle(.plain)
    }
}

#Preview {
    OptionsPickerSelectedImageView(
        imageInfo: PickedImageInfo(
            attachEntity: .mock(),
            imageFileURL: URL(fileURLWithPath: "/Users/macintosh/WindowsISO/Windows10.iso")
        ),
        onRemove: { }
    )
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .padding()
}
