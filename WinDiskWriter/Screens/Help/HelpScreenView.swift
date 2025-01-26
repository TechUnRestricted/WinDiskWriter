//
//  HelpScreenView.swift
//  WinDiskWriter
//
//  Created by Macintosh on 14.12.2024.
//

import SwiftUI

struct HelpScreenView: View {
    init() {
        
    }
    
    var body: some View {
        VStack {
            Text("Help")
            
            Button("Restart") {
                Task {
                    try await AppRelauncher.restartApp(withElevatedPermissions: true)
                }
            }
        }
    }
}
