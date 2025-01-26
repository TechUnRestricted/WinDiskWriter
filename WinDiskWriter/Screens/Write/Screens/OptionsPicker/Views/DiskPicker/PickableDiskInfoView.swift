//
//  PickableDiskInfoView.swift
//  WinDiskWriter
//
//  Created by Macintosh on 29.12.2024.
//

import SwiftUI

struct PickableDiskInfoView: View {
    private let diskInfo: DiskInfo
    private let approximateMinimumSpaceRequired: UInt64
    
    private var isInternal: Bool {
        diskInfo.device.isInternal ?? false
    }
    
    private var protocolType: String? {
        diskInfo.device.protocol
    }
    
    private var mediaName: String {
        if let mediaName = diskInfo.media.name {
            return mediaName.stripped()
        }
        
        let vendorName: String = diskInfo.device.vendor?.stripped() ?? ""
        let modelName: String = diskInfo.device.model?.stripped() ?? ""
        
        let fallbackDiskNameResult: String = (vendorName + " " + modelName).stripped()
        guard !fallbackDiskNameResult.isEmpty else {
            return fallbackDiskNameResult
        }
        
        return LocalizedStringResource("Unknown Disk").stringValue
    }
    
    private var bsdName: String {
        diskInfo.media.bsdName
    }
    
    private var diskCapacityFormatted: String? {
        diskInfo.media.size?.formattedSize
    }
    
    private var approximateMinimumSpaceRequiredFormatted: String {
        approximateMinimumSpaceRequired.formattedSize
    }
    
    private var isNotEnoughSpace: Bool {
        let diskSpace: UInt64 = (diskInfo.media.size ?? 0)
        
        return diskSpace < approximateMinimumSpaceRequired
    }
    
    init(diskInfo: DiskInfo, approximateMinimumSpaceRequired: UInt64) {
        self.diskInfo = diskInfo
        self.approximateMinimumSpaceRequired = approximateMinimumSpaceRequired
    }

    var body: some View {
        contentView
    }
    
    private var contentView: some View {
        HStack(alignment: .center, spacing: 14) {
            diskImageView
            diskInfoView
            
            Spacer()
            
            diskProtocolTextView
        }
    }
    
    @ViewBuilder
    private var diskImageView: some View {
        var nsImage: NSImage {
            if isInternal {
                // Gray internal disk icon
                return NSWorkspace.shared.icon(
                    forFileTypeUndeprecated: NSFileTypeForHFSTypeCode(OSType(kGenericHardDiskIcon))
                )
            } else {
                // Yellow external disk icon
                return NSWorkspace.shared.icon(
                    forFileTypeUndeprecated: NSFileTypeForHFSTypeCode(OSType(kGenericRemovableMediaIcon))
                )
            }
        }
        
        Image(nsImage: nsImage)
    }
    
    private var diskInfoView: some View {
        VStack(alignment: .leading) {
            Text(mediaName)
                .font(.headline)
            
            if let diskCapacityFormatted {
                HStack(alignment: .center, spacing: 4) {
                    Text(diskCapacityFormatted)
                        .font(.subheadline)
                        .bold()

                    if isNotEnoughSpace {
                        Text("(Required: \(approximateMinimumSpaceRequiredFormatted))")
                            .font(.subheadline)
                            .fontWeight(.light)
                    }
                }
                .opacity(0.85)
                .if(isNotEnoughSpace) {
                    $0.foregroundStyle(.red)
                }
            }
        }
        .lineLimit(1)
    }
    
    @ViewBuilder
    private var diskProtocolTextView: some View {
        VStack(alignment: .center) {
            if let protocolType {
                Text(protocolType)
                    .font(.callout)
                    .tracking(1)
                    .bold()
            }
            
            Text(bsdName)
                .font(.footnote)
                .fontWeight(.ultraLight)
        }
        .lineLimit(1)
        .opacity(0.35)
    }
}

#Preview {
    PickableDiskInfoView(diskInfo: .mock(), approximateMinimumSpaceRequired: 1024 * 1024 * 1024 * 1024 * 1024)
}
