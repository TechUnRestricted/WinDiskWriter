//
//  View+Bordered.swift
//  WinDiskWriter
//
//  Created by Macintosh on 13.12.2024.
//

import SwiftUI

extension View {
    func bordered(cornerRadius: CGFloat, color: Color, lineWidth: CGFloat = 1, clipsToShape: Bool = true) -> some View {
        self
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(color, lineWidth: lineWidth)
            )
            .if(clipsToShape) { view in
                view
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            }
    }
}
