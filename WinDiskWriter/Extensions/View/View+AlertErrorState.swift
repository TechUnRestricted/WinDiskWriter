//
//  View+AlertErrorState.swift
//  WinDiskWriter
//
//  Created by Macintosh on 22.12.2024.
//

import SwiftUI

extension View {
    func alert<V: View>(errorState: Binding<ErrorState?>, @ViewBuilder actions: () -> V) -> some View {
        let title = errorState.wrappedValue?.title ?? LocalizedStringResource("Unknown Error").stringValue
        
        let isPresented = Binding<Bool>(get: {
            errorState.wrappedValue != nil
        }, set: { shouldDisplay in
            if !shouldDisplay {
                errorState.wrappedValue = nil
            }
        })
        
        return self.overlay {
            EmptyView()
                .alert(
                    title,
                    isPresented: isPresented,
                    presenting: errorState,
                    actions: { _ in
                        actions()
                    }, message: { errorState in
                        if let description = errorState.wrappedValue?.description {
                            Text(description)
                        }
                    }
                )
        }
    }
}
