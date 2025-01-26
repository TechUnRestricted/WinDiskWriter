//
//  View+If-Else.swift
//  WinDiskWriter
//
//  Created by Macintosh on 12.12.2024.
//

import SwiftUI

extension View {
    func `if`<TrueContent: View, FalseContent: View>(
        _ condition: Bool,
        transform: (Self) -> TrueContent,
        else elseTransform: (Self) -> FalseContent
    ) -> some View {
        if condition {
            return transform(self).eraseToAnyView()
        } else {
            return elseTransform(self).eraseToAnyView()
        }
    }
}

