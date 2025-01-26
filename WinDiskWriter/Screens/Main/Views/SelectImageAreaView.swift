//
//  SelectImageAreaView.swift
//  WinDiskWriter
//
//  Created by Macintosh on 14.12.2024.
//

import SwiftUI

struct SelectImageAreaView: View {
    @Binding private var droppedFileURL: URL?
    
    @State private var isDragging: Bool = false
    @State private var isFilePickerDisplayed: Bool = false
    
    private let viewModel = SelectImageAreaViewModel()
    
    private var isImagePicked: Bool {
        droppedFileURL != nil
    }
    
    init(droppedFileURL: Binding<URL?>) {
        self._droppedFileURL = droppedFileURL
    }
    
    var body: some View {
        contentView
            .scaleEffect(isDragging ? 1.1 : 1.0)
            .onDrop(of: [SelectImageAreaConstants.fileType], isTargeted: $isDragging) { providers in
                viewModel.handleDrop(providers: providers, droppedFileURL: $droppedFileURL)
            }
            .fileImporter(
                isPresented: $isFilePickerDisplayed,
                allowedContentTypes: [.iso],
                onCompletion: { result in
                    switch result {
                    case .success(let url):
                        droppedFileURL = url
                    case .failure(let error):
                        print("Can't process selected file \(error.localizedDescription)")
                    }
                }
            )
            .animation(.easeInOut, value: isDragging)
    }

    private var contentView: some View {
        VStack(spacing: 16) {
            imageIconView

            textContainer

            chooseFileButton
        }
        .padding(44)
        .padding(.horizontal, 30)
        .background(draggingBackgroundView)
        .overlay(contentOutlineView)
    }

    private var draggingBackgroundView: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(isDragging ? Color.accentColor.opacity(0.2) : Color.clear)
    }

    private var contentOutlineView: some View {
        RoundedRectangle(cornerRadius: 12)
            .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
            .foregroundColor(isDragging ? Color.accentColor : Color.gray)
    }

    private var imageIconView: some View {
        Image(systemName: "opticaldisc.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 48, height: 48)
            .foregroundStyle(isDragging ? Color.accentColor : .gray)
    }

    private var textContainer: some View {
        VStack(spacing: 8) {
            titleView
                .fontWeight(.medium)
                .font(.title2)

            subtitleView
                .fontWeight(.light)
                .font(.subheadline)
                .opacity(0.5)
        }
    }

    private var titleView: some View {
        Text(isImagePicked ? "Image Picked" : "Select Windows ISO Image")
    }

    @ViewBuilder
    private var subtitleView: some View {
        if let droppedFileURL {
            let fileSize: String = droppedFileURL.formattedFileSize() ?? LocalizedStringResource("Unknown Size").stringValue
            
            Text(verbatim: "\(droppedFileURL.lastPathComponent) (\(fileSize))")
                .lineLimit(3)
                .truncationMode(.middle)
        } else {
            Text("Drag and drop your Windows ISO file here, or click to select")
        }
    }

    private var chooseFileButton: some View {
        Button(
            action: {
                isFilePickerDisplayed = true
            },
            label: {
                HStack(spacing: 8) {
                    Image(systemName: isImagePicked ? "arrow.2.circlepath" : "arrow.up.doc.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 11, height: 14)
                    
                    Text(isImagePicked ? "Change File" : "Choose File")
                }
                .padding(6)
                .padding(.horizontal, 18)
            }
        )
        .buttonStyle(.bordered)
        .opacity(isImagePicked ? 0.85 : 1.0)
    }
}

#Preview {
    SelectImageAreaView(droppedFileURL: .constant(URL(filePath: "")))
        .padding()
}
