//
//  List+ApplyListSheetStyling.swift
//  WinDiskWriter
//
//  Created by Macintosh on 30.12.2024.
//

import SwiftUI

extension List {
    func applyListSheetStyling() -> some View {
        self
            .scrollContentBackground(.hidden)
            .listStyle(PlainListStyle())
            .apply {
                if #available(macOS 14.0, *) {
                    $0.scrollIndicatorsFlash(onAppear: true).eraseToAnyView()
                } else {
                    $0.eraseToAnyView()
                }
            }
    }
}
