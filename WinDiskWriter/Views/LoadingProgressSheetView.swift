//
//  LoadingProgressSheetView.swift
//  WinDiskWriter
//
//  Created by Macintosh on 25.12.2024.
//

import SwiftUI

private enum Constants {
    static let padding: CGFloat = 16
}

struct LoadingProgressSheetView: View {
    private let title: String
    
    init(title: LocalizedStringResource) {
        self.title = title.stringValue
    }
    
    @_disfavoredOverload
    init(title: String) {
        self.title = title
    }
    
    var body: some View {
        contentView
            .padding(Constants.padding)
            .padding(.horizontal, Constants.padding / 4)
    }
    
    private var contentView: some View {
        HStack(alignment: .center, spacing: Constants.padding) {
            ProgressView()
            
            Text(title)
        }
    }
}
