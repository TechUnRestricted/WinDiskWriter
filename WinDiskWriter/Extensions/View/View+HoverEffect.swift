//
//  View+HoverEffect.swift
//  WinDiskWriter
//
//  Created by Macintosh on 21.12.2024.
//

import SwiftUI

extension View {
    /// Adds a hover effect to the view and updates the provided state binding when the hover state changes.
    /// - Parameter isHovering: A `Binding` to a `Bool` that indicates whether the mouse is hovering over the view.
    /// - Returns: A view that tracks hover state.
    func hoverEffect(isHovering: Binding<Bool>) -> some View {
        self
            .onHover { hovering in
                isHovering.wrappedValue = hovering
            }
    }
}
