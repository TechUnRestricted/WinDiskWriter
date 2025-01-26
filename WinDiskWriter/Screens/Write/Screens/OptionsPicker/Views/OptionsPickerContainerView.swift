//
//  OptionsPickerContainerView.swift
//  WinDiskWriter
//
//  Created by Macintosh on 28.12.2024.
//

import SwiftUI

struct OptionsPickerContainerView<Content: View>: View {
    private let title: String
    private let content: Content
    private let rightView: AnyView?

    init(
        title: LocalizedStringResource,
        @ViewBuilder content: () -> Content,
        @ViewBuilder rightView: @escaping () -> AnyView? = { nil }
    ) {
        self.init(title: title.stringValue, content: content, rightView: rightView)
    }
    
    @_disfavoredOverload
    init(
        title: String,
        @ViewBuilder content: () -> Content,
        @ViewBuilder rightView: @escaping () -> AnyView? = { nil }
    ) {
        self.title = title
        self.content = content()
        self.rightView = rightView() ?? nil
    }
    
    var body: some View {
        containerView
    }

    private var containerView: some View {
        VStack(alignment: .leading, spacing: 14) {
            headerView
            content
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.gray.opacity(0.1))
        .bordered(cornerRadius: 16, color: .gray.opacity(0.2))
    }

    private var headerView: some View {
        HStack {
            Text(title)
                .font(.headline)
                .fontWeight(.medium)
            
            Spacer()
            
            if let rightView = rightView {
               rightView
            }
        }
    }
}


#Preview {
    OptionsPickerContainerView(
        title: "Selected Image",
        content: {
            VStack(alignment: .leading, spacing: 10) {
                Text("This is the main content of the container.")
                    .font(.body)
                    .foregroundColor(.primary)
                Text("You can add any custom views here.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(Color.gray.opacity(0.1))
            .bordered(cornerRadius: 8, color: .gray.opacity(0.25))
        },
        rightView: {
            HelpButtonView(text: "Hello World" as String).eraseToAnyView()
        }
    )
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .padding()
}
