//
//  SupportedImageListEntryView.swift
//  WinDiskWriter
//
//  Created by Macintosh on 21.12.2024.
//

import SwiftUI

struct SupportedImageListEntryView: View {
    private let imageSupportInfo: ImageSupportInfo
    
    init(imageSupportInfo: ImageSupportInfo) {
        self.imageSupportInfo = imageSupportInfo
    }
    
    var body: some View {
        contentView
            .padding(14)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
    }
    
    private var contentView: some View {
        VStack(alignment: .leading, spacing: 10) {
            mainInfoView
            
            if let importantNotes = imageSupportInfo.importantNotes {
                Text(importantNotes)
                    .font(.caption2)
                    .lineLimit(2)
                    .opacity(0.2)
                    .multilineTextAlignment(.leading)
            }
        }
    }
    
    private var mainInfoView: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(imageSupportInfo.title)
                .font(.title2)
            
            archsBootModeInfoView
        }
        .lineLimit(1, reservesSpace: true)
    }
    
    private var archsBootModeInfoView: some View {
        HStack(alignment: .center, spacing: 8) {
            Text(imageSupportInfo.archsListString)
                
            Spacer()
            
            Text(imageSupportInfo.bootModesListString)
        }
        .foregroundStyle(.gray)
        .opacity(0.80)
    }
}

#Preview {
    SupportedImageListEntryView(
        imageSupportInfo: ImageSupportInfo(
            title: "Windows 11",
            archs: [.x86_64, .x86_32],
            bootModes: [.uefi, .legacy],
            importantNotes: "Requires Intel Core i-Series CPU or newer"
        )
    )
    .padding(24)
}
