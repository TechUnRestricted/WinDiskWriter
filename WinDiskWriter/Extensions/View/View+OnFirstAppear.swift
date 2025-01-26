//
//  View+OnFirstAppear.swift
//  WinDiskWriter
//
//  Created by Macintosh on 15.12.2024.
//


import SwiftUI

struct OnFirstAppearModifier: ViewModifier {
    @State private var firstTime: Bool = true
    
    private let perform:() -> Void
    
    init(perform: @escaping () -> Void) {
        self.perform = perform
    }
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                if firstTime {
                    firstTime = false
                    self.perform()
                }
            }
    }
}

extension View {
    func onFirstAppear( perform: @escaping () -> Void ) -> some View {
        return self.modifier(OnFirstAppearModifier(perform: perform))
    }
}
