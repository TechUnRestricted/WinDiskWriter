//
//  ImagePickerScreenView.swift
//  WinDiskWriter
//
//  Created by Macintosh on 21.12.2024.
//

import SwiftUI

class ImagePickerScreenViewModel: ObservableObject {
    @Published var isDisplayingSupportedImagesSheet: Bool = false
    @Published var isDisplayingAttachingSheet: Bool = false
    
    @Published var imageFileURL: URL?
    @Published var imageAttachError: ErrorState?
    
    @MainActor
    func attachImage() async -> HDIUtilAttachEntity? {
        isDisplayingAttachingSheet = true
        defer { isDisplayingAttachingSheet = false }
        
        guard let imageFileURL = imageFileURL else {
            return nil
        }

        do {
            let attachResult = try await HDIUtil.attach(imageURL: imageFileURL)
            let entities = attachResult.entities
            
            guard !entities.isEmpty else {
                self.imageAttachError = ErrorState(
                    title: LocalizedStringResource("No Volumes Found").stringValue,
                    description: LocalizedStringResource("The disk image does not contain any volumes to attach.").stringValue
                )
                
                return nil
            }
            
            guard entities.count == 1 else {
                self.imageAttachError = ErrorState(
                    title: LocalizedStringResource("Multiple Volumes Found").stringValue,
                    description: LocalizedStringResource("The disk image contains multiple volumes, which is not supported.").stringValue
                )
                
                return nil
            }
            
            guard let firstEntity = entities.first else {
                return nil
            }
            
            return firstEntity
        } catch {
            DispatchQueue.main.async { [weak self] in
                self?.imageAttachError = ErrorState(
                    title: LocalizedStringResource("Image Mount Failure").stringValue,
                    description: error.localizedDescription
                )
            }            
        }
        
        return nil
    }
}
