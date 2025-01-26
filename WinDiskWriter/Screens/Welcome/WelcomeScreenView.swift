//
//  WelcomeScreenView.swift
//  WinDiskWriter
//
//  Created by Macintosh on 13.12.2024.
//

import SwiftUI

private enum Constants {
    static let imageSize: CGFloat = 160
    
    static let contentMinWidth: CGFloat = 710
    static let contentMinHeight: CGFloat = 560
}

class WelcomeScreenViewModel: ObservableObject {
    func openSourceCodeWebPage() {
        GlobalConstants.Links.sourceCodePage.open()
    }
}

struct WelcomeScreenView: View {
    @StateObject private var viewModel = WelcomeScreenViewModel()
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        contentView
        //.transparentTitleBar()
        //.navigationTitle("")
            .opacity(0.90)
            .padding([.horizontal, .bottom], GlobalConstants.defaultWindowPadding)
            .frame(minWidth: Constants.contentMinWidth, minHeight: Constants.contentMinHeight)
            .background(BackdropBlurVisualEffectView(blendingMode: .behindWindow))
        //.movableByWindowBackground()
            .fixedSize()
    }
    
    private var contentView: some View {
        VStack(spacing: 0) {
            appIconView
            
            appMainInfoTextContainerView
            
            featuresView
                .padding(.top, 25)
            
            actionButtonsContainerView
                .padding(.top, 30)
        }
    }
    
    private var appIconView: some View {
        Image.appIcon
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: Constants.imageSize, height: Constants.imageSize)
    }
    
    private var appMainInfoTextContainerView: some View {
        VStack(alignment: .center, spacing: 6) {
            appTitleView
            
            appSubtitleView
        }
    }
    
    private var appTitleView: some View {
        Text("WinDiskWriter")
            .font(.system(size: 47))
            .fontWeight(.light)
    }
    
    private var appSubtitleView: some View {
        Text("Windows bootable disk creator for macOS")
            .font(.system(size: 15))
            .fontWeight(.thin)
    }
    
    private var featuresView: some View {
        WelcomeScreenFeaturesView()
            .frame(maxWidth: 560, alignment: .leading)
            .padding(.horizontal, 65)
    }
    
    private var actionButtonsContainerView: some View {
        HStack {
            sourceCodeButton
            
            Spacer()
        }
        .overlay(
            continueButton,
            alignment: .center
        )
    }
    
    private var sourceCodeButton: some View {
        TexturedRoundedButton("Source Code") {
            viewModel.openSourceCodeWebPage()
        }
        .fixedSize()
    }
    
    private var continueButton: some View {
        ProminentButton(
            title: "Continue",
            executesOnReturn: true,
            action: dismissWithAnimation
        )
    }
    
    private func dismissWithAnimation() {
        withAnimation(.easeInOut) {
            dismiss()
        }
    }
}

#Preview {
    WelcomeScreenView()
}
