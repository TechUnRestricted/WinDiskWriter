//
//  HelpButtonView.swift
//  WinDiskWriter
//
//  Created by Macintosh on 28.12.2024.
//

import SwiftUI

private enum Constants {
    static let imageSize: CGFloat = 16
}

struct HelpButtonView: View {
    private let text: String
    
    @State private var isDisplayingPopOver: Bool = false
    
    init(text: LocalizedStringResource) {
        self.init(text: text.stringValue)
    }
    
    @_disfavoredOverload
    init(text: String) {
        self.text = text
    }
    
    var body: some View {
        contentView
            .popover(isPresented: $isDisplayingPopOver) {
                popoverContent
            }
            .if(!isDisplayingPopOver) {
                $0.help(text)
            }
    }
    
    private var contentView: some View {
        buttonView
    }
    
    private var buttonView: some View {
        Button(action: {
            isDisplayingPopOver = true
        }, label: {
            imageView
        })
        .buttonStyle(.plain)
    }
    
    private var imageView: some View {
        Image(systemName: "info.bubble")
            .frame(width: Constants.imageSize, height: Constants.imageSize)
            .aspectRatio(1/1, contentMode: .fit)
            .scaleEffect(0.8)
            .padding(5)
            .background(.gray.opacity(0.2))
            .bordered(cornerRadius: .greatestFiniteMagnitude, color: .gray.opacity(0.2), lineWidth: 2)
    }
    
    private var popoverContent: some View {
        Text(text)
            .multilineTextAlignment(.leading)
            .padding()
            .frame(width: 360)
    }
}

#Preview {
    HelpButtonView(text: "This is an example text. ".multiplied(by: 5).stripped())
        .padding(44)
}

