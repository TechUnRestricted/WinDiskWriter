//
//  WelcomeScreenFeaturesView.swift
//  WinDiskWriter
//
//  Created by Macintosh on 13.12.2024.
//

import SwiftUI

private enum Constants {
    static let backgroundCornerRadius: CGFloat = 16
}

private struct WelcomeScreenFeatureEntry: Identifiable {
    let id: UUID = UUID()
    
    let image: Image
    let title: String
    
    init(image: Image, title: String) {
        self.image = image
        self.title = title
    }
    
    static func getList() -> [WelcomeScreenFeatureEntry] {
        let windowsSupportEntry = WelcomeScreenFeatureEntry(
            image: Image(systemName: "opticaldisc"),
            title: LocalizedStringResource("Supports all Windows versions from the past 18 years").stringValue
        )
        
        let tpmSecureBootPatchEntry = WelcomeScreenFeatureEntry(
            image: Image(systemName: "lock.open.laptopcomputer"),
            title: LocalizedStringResource("Enables TPM and Secure Boot bypass for seamless Windows 11 installation").stringValue
        )
        
        let uefiLegacyBootModesEntry = WelcomeScreenFeatureEntry(
            image: Image(systemName: "gearshape.2"),
            title: LocalizedStringResource("Allows to boot with UEFI or Legacy modes").stringValue
        )
        
        return [windowsSupportEntry, tpmSecureBootPatchEntry, uefiLegacyBootModesEntry]
    }
}

struct WelcomeScreenFeaturesView: View {
    var body: some View {
        contentView
            .frame(maxWidth: .infinity)
            .background(backgroundView)
    }
    
    private var backgroundView: some View {
        BackdropBlurVisualEffectView(blendingMode: .withinWindow)
            .bordered(
                cornerRadius: Constants.backgroundCornerRadius,
                color: .secondary.opacity(0.30)
            )
    }
    
    private var contentView: some View {
        VStack(alignment: .center, spacing: 14) {
            ForEach(WelcomeScreenFeatureEntry.getList()) { featureEntry in
                createFeatureInfoEntry(for: featureEntry)
            }
        }
        .padding(30)
    }
    
    private func createFeatureInfoEntry(for featureEntry: WelcomeScreenFeatureEntry) -> some View {
        HStack(spacing: 0) {
            HStack(alignment: .center, spacing: 20) {
                featureEntry.image
                    .font(.system(size: 28))
                    .frame(width: 40)
                    .clipped()
                
                Text(featureEntry.title)
                    .font(.system(size: 16, weight: .thin))
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
            }
            
            Spacer()
        }
    }
}

#Preview {
    VStack {
        WelcomeScreenFeaturesView()
    }
    .padding(24)
    .background(BackdropBlurVisualEffectView(blendingMode: .behindWindow))
}
