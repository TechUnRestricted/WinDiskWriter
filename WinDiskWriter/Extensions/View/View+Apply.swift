//
//  View+Apply.swift
//  WinDiskWriter
//
//  Created by Macintosh on 14.12.2024.
//

import SwiftUI

extension View {
    /// Conditionally applies the given transformation to the view.
    @ViewBuilder
    func apply<Content: View>(_ transform: (Self) -> Content) -> some View {
        transform(self)
    }
}
