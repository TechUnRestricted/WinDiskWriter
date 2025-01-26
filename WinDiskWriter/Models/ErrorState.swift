//
//  ErrorState.swift
//  WinDiskWriter
//
//  Created by Macintosh on 22.12.2024.
//

import SwiftUI

struct ErrorState: Identifiable, Equatable {
    let id = UUID()
    
    let title: String
    let description: String?
    let image: Image?

    init(title: String, description: String?, image: Image? = nil) {
        self.title = title
        self.description = description
        self.image = image
    }
    
    static func ==(lhs: ErrorState, rhs: ErrorState) -> Bool {
        return lhs.id == rhs.id
    }
}
