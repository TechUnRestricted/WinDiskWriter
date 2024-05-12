//
//  AboutViewModel.swift
//  WinDiskWriter
//
//  Created by Macintosh on 11.05.2024.
//

import Foundation

typealias LicenseFileName = String
typealias LicenseFileText = String

final class AboutViewModel: NSObject {
    private enum Constants {
        static let licenseDirectory: String = "Licenses"
        static let licenseFileExtension: String = "lic"
        static let licenseMaxFileSize: UInt64 = 128_000
    }

    @objc dynamic var licenses: [LicenseFileName: LicenseFileText] = [:]

    private let coordinator: AboutCoordinator

    init(coordinator: AboutCoordinator) {
        self.coordinator = coordinator

        super.init()

        loadLicenses()
    }

    func loadLicenses() {
        var licenseURLs: [URL] = []

        do {
            licenseURLs = try Bundle.listFiles(
                in: Constants.licenseDirectory,
                withExtension: Constants.licenseFileExtension
            )
        } catch {
            return
        }

        let fileReader = FileReader(maxFileSize: Constants.licenseMaxFileSize)

        var updatedLicenses: [LicenseFileName: LicenseFileText] = [:]

        for licenseURL in licenseURLs {
            do {
                let licenseFileName = licenseURL.lastPathComponent
                let licenseData = try fileReader.readFile(from: licenseURL)

                guard let licenseText = String(data: licenseData, encoding: .utf8) else {
                    continue
                }

                updatedLicenses[licenseFileName] = licenseText
            } catch {
                continue
            }
        }

        licenses = updatedLicenses
    }

    func openDevelopersGitHubPage() {
        URL(string: GlobalConstants.developersGitHubLink)?.open()
    }
}
