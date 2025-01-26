//
//  View+ReadSize.swift
//  WinDiskWriter
//
//  Created by Macintosh on 14.12.2024.
//

import SwiftUI

private struct SizeReaderModifier: ViewModifier {
    @Binding private var size: CGSize
    private var readOnce: Bool = false
    
    init(size: Binding<CGSize>, readOnce: Bool) {
        self._size = size
        self.readOnce = readOnce
    }
    
    func body(content: Content) -> some View {
        content.background(
            GeometryReader { geometry in
                Color.clear
                    .onAppear {
                        DispatchQueue.main.async {
                            size = geometry.size
                        }
                    }
                    .if(!readOnce) { view in
                        view.onChange(of: geometry.size) { newSize in
                            DispatchQueue.main.async {
                                size = newSize
                            }
                        }
                    }
            }
        )
    }
}

extension View {
    func readSize(_ size: Binding<CGSize>, readOnce: Bool = false) -> some View {
        self.modifier(SizeReaderModifier(size: size, readOnce: readOnce))
    }
}
