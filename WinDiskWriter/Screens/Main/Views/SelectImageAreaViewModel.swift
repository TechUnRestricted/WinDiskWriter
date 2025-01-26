//
//  SelectImageAreaViewModel.swift
//  WinDiskWriter
//
//  Created by Macintosh on 15.12.2024.
//

import SwiftUI

class SelectImageAreaViewModel: ObservableObject {
    func handleDrop(providers: [NSItemProvider], droppedFileURL: Binding<URL?>) -> Bool {
        guard let provider = providers.first(where: { $0.hasItemConformingToTypeIdentifier(SelectImageAreaConstants.fileType) }) else {
            return false
        }

        provider.loadItem(forTypeIdentifier: SelectImageAreaConstants.fileType, options: nil) { item, error in
            guard error == nil, let data = item as? Data else { return }
            
            guard let fileURL = URL(dataRepresentation: data, relativeTo: nil), fileURL.pathExtension.lowercased() == "iso" else {
                print("Invalid file type")
                return
            }
            
            DispatchQueue.main.async {
                droppedFileURL.wrappedValue = fileURL
            }
        }

        return true
    }
}
