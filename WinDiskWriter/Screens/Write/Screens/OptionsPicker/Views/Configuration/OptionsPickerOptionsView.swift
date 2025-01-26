//
//  OptionsPickerOptionsView.swift
//  WinDiskWriter
//
//  Created by Macintosh on 30.12.2024.
//

import SwiftUI

struct OptionsPickerOptionsView: View {
    @Binding private var _isInstallLegacyBootSectorEnabled: Bool
    private var isInstallLegacyBootSectorEnabled: Binding<Bool> {
        Binding(
            get: { _isInstallLegacyBootSectorEnabled },
            set: { shouldEnable in
                if shouldEnable && !AppHelper.hasElevatedPermissions() {
                    isDisplayingRelaunchPrompt = true
                    return
                }
                _isInstallLegacyBootSectorEnabled = shouldEnable
            }
        )
    }
    
    @Binding private var isPatchWindowsInstallerEnabled: Bool

    @State private var isDisplayingRelaunchPrompt: Bool = false
    @State private var isInstallLegacyBootSectorButtonAvailable: Bool = true
    
    @State private var errorState: ErrorState?
    
    init(isInstallLegacyBootSectorEnabled: Binding<Bool>, isPatchWindowsInstallerEnabled: Binding<Bool>) {
        __isInstallLegacyBootSectorEnabled = isInstallLegacyBootSectorEnabled
        _isPatchWindowsInstallerEnabled = isPatchWindowsInstallerEnabled
    }
    
    var body: some View {
        contentView
            .alert(
                "Legacy Boot Support",
                isPresented: $isDisplayingRelaunchPrompt,
                actions: {
                    Button("Cancel", role: .cancel) {
                        
                    }
                    
                    Button("Continue", role: .destructive) {
                        relaunchApp()
                    }
                },
                message: {
                    Text("This operation requires administrator privileges — you'll be prompted for your password.")
                }
            )
            .alert(
                errorState: $errorState,
                actions: {
                    Button("Discard") {
                        
                    }
                }
            )
    }
    
    private var contentView: some View {
        OptionsPickerContainerView(title: "Additional Options") {
            VStack(alignment: .leading, spacing: 8) {
                installLegacyBootSectorCheckboxView
                patchWindowsInstallerCheckboxView
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private var installLegacyBootSectorCheckboxView: some View {
        Toggle("Install Legacy Boot Sector", isOn: isInstallLegacyBootSectorEnabled)
            .disabled(!isInstallLegacyBootSectorButtonAvailable)
    }
    
    private var patchWindowsInstallerCheckboxView: some View {
        Toggle("Patch Windows Installer Requirements", isOn: $isPatchWindowsInstallerEnabled)
    }
    
    private func relaunchApp() {
        Task.runWithCompletion($isInstallLegacyBootSectorButtonAvailable) {
            do {
                try await AppRelauncher.restartApp(withElevatedPermissions: true)
            } catch {
                await MainActor.run {
                    errorState = ErrorState(
                        title: LocalizedStringResource("Unable to relaunch the application").stringValue,
                        description: error.localizedDescription
                    )
                }
            }
        }
    }
}

#Preview {
    OptionsPickerOptionsView(
        isInstallLegacyBootSectorEnabled: .constant(true),
        isPatchWindowsInstallerEnabled: .constant(false)
    )
    .padding(44)
}
