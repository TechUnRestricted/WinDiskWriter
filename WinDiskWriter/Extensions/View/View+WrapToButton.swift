//
//  View+WrapToButton.swift
//  WinDiskWriter
//
//  Created by Macintosh on 29.12.2024.
//

import SwiftUI

extension View {
    func wrapToButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            self
        }
        .buttonStyle(PlainButtonStyle())
    }
}
