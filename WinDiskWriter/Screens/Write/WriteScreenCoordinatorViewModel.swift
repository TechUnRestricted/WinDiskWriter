//
//  WriteScreenCoordinatorViewModel.swift
//  WinDiskWriter
//
//  Created by Macintosh on 22.12.2024.
//

import SwiftUI

class WriteScreenCoordinatorViewModel: ObservableObject {
    @Published var stage: WriteScreenStage = .imagePicker
    
    func reset() {
        self.stage = .imagePicker
    }
}
