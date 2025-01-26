//
//  WriteScreenCoordinatorView.swift
//  WinDiskWriter
//
//  Created by Macintosh on 14.12.2024.
//

import SwiftUI

enum WriteScreenStage: Equatable {
    case imagePicker
    case optionsPicker(imageInfo: PickedImageInfo)
    
    static func == (lhs: WriteScreenStage, rhs: WriteScreenStage) -> Bool {
        switch (lhs, rhs) {
        case (.imagePicker, .imagePicker):
            return true
        case let (.optionsPicker(leftImageInfo), .optionsPicker(rightImageInfo)):
            return leftImageInfo == rightImageInfo
        default:
            return false
        }
    }
}

struct WriteScreenCoordinatorView: View {
    @StateObject private var viewModel = WriteScreenCoordinatorViewModel()
     
    var body: some View {
        contentView
    }
    
    private var contentView: some View {
        VStack(alignment: .center) {
            switch viewModel.stage {
            case .imagePicker:
                imagePickerView
            case .optionsPicker(let imageInfo):
                optionsPickerView(imageInfo: imageInfo)
            }
        }
        .animation(.snappy.speed(1.5), value: viewModel.stage)
    }
    
    private var imagePickerView: some View {
        ImagePickerScreenView(onAttach: { imageInfo in
            viewModel.stage = .optionsPicker(imageInfo: imageInfo)
        })
    }
    
    private func optionsPickerView(imageInfo: PickedImageInfo) -> some View {
        OptionsPickerView(imageInfo: imageInfo, onImageRemove: {
            viewModel.reset()
        })
    }
}
