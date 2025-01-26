//
//  MainContentScreenType.swift
//  WinDiskWriter
//
//  Created by Macintosh on 14.12.2024.
//

import Foundation
import SwiftUI

enum MainContentScreenType: CaseIterable, Identifiable {
    case write
    case donations
    case help
    case about
    
    var id: Self {
        return self
    }

    var shortTitle: String {
        switch self {
        case .write:
            return LocalizedStringResource("Write").stringValue
        case .donations:
            return LocalizedStringResource("Donations ❤️").stringValue
        case .help:
            return LocalizedStringResource("Help").stringValue
        case .about:
            return LocalizedStringResource("About").stringValue
        }
    }
    
    var regularTitle: String {
        switch self {
        case .write:
            return LocalizedStringResource("Create Bootable Drive").stringValue
        case .donations:
            return LocalizedStringResource("Support the Project").stringValue
        case .help:
            return LocalizedStringResource("Help and Troubleshooting").stringValue
        case .about:
            return LocalizedStringResource("About the Application").stringValue
        }
    }

    var subtitle: String {
        switch self {
        case .write:
            return LocalizedStringResource("Easily create a Windows bootable drive on macOS").stringValue
        case .donations:
            return LocalizedStringResource("Contribute to the project's development").stringValue
        case .help:
            return LocalizedStringResource("Find answers to common issues and guides").stringValue
        case .about:
            return LocalizedStringResource("Learn more about this application").stringValue
        }
    }

    var iconSystemName: String {
        switch self {
        case .write:
            return "externaldrive"
        case .donations:
            return "bolt.heart"
        case .about:
            return "info.circle"
        case .help:
            return "exclamationmark.bubble"
        }
    }
    
    var destination: any View {
        switch self {
        case .write:
            WriteScreenCoordinatorView()
        case .donations:
            DonationsScreenView()
        case .about:
            AboutScreenView()
        case .help:
            HelpScreenView()
        }
    }
}
