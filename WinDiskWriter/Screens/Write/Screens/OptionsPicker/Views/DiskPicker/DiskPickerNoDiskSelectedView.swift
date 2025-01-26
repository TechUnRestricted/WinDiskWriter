//
//  DiskPickerNoDiskSelectedView.swift
//  WinDiskWriter
//
//  Created by Macintosh on 29.12.2024.
//

import SwiftUI

struct DiskPickerNoDiskSelectedView: View {
    var body: some View {
        contentView
    }
    
    private var contentView: some View {
        HStack(alignment: .center, spacing: 14) {
            imageView
            
            verticalContainerView
            
            Spacer()
        }
    }
    
    private var verticalContainerView: some View {
        VStack(alignment: .leading, spacing: 2) {
            titleTextView
            subtitleTextView
        }
    }
    
    private var imageView: some View {
        Image(systemName: "externaldrive.badge.plus")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 22)
    }
    
    private var titleTextView: some View {
        Text("Select the destination device")
            .font(.title3)
    }
    
    private var subtitleTextView: some View {
        Text("Click to open the list of available disks")
            .font(.caption)
            .opacity(0.35)
    }
}

#Preview {
    DiskPickerNoDiskSelectedView()
}
