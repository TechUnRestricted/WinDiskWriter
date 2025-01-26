//
//  ImageSupportInfo.swift
//  WinDiskWriter
//
//  Created by Macintosh on 21.12.2024.
//

import Foundation

private enum Constants {
    static let collectionSeparator: String = " | "
}

struct ImageSupportInfo: Identifiable {
    let id = UUID()
    let title: String
    let archs: Set<ProcessorArchirecture>
    let bootModes: Set<BootMode>
    let importantNotes: String?
    
    var archsListString: String {
        archs.joinedSorted(
            by: { $0.rawValue > $1.rawValue },
            separator: Constants.collectionSeparator,
            transform: { $0.windowsStyledDescription }
        )
    }
    
    var bootModesListString: String {
        bootModes.joinedSorted(
            by: { $0.rawValue > $1.rawValue },
            separator: Constants.collectionSeparator,
            transform: { $0.rawValue }
        )
    }
    
    init(
        title: String,
        archs: Set<ProcessorArchirecture>,
        bootModes: Set<BootMode>,
        importantNotes: String? = nil
    ) {
        self.title = title
        self.archs = archs
        self.bootModes = bootModes
        self.importantNotes = importantNotes
    }
}

extension ImageSupportInfo {
    static func createList() -> [Self] {
        [
            ImageSupportInfo(
                title: "Windows 11",
                archs: [.x86_64],
                bootModes: [.uefi, .legacy]
            ),
            ImageSupportInfo(
                title: "Windows 10",
                archs: [.x86_64, .x86_32],
                bootModes: [.uefi, .legacy]
            ),
            ImageSupportInfo(
                title: "Windows 8.1",
                archs: [.x86_64, .x86_32],
                bootModes: [.uefi, .legacy]
            ),
            ImageSupportInfo(
                title: "Windows 8",
                archs: [.x86_64, .x86_32],
                bootModes: [.uefi, .legacy]
            ),
            ImageSupportInfo(
                title: "Windows 7",
                archs: [.x86_64, .x86_32],
                bootModes: [.uefi, .legacy]
            ),
            ImageSupportInfo(
                title: "Windows Vista",
                archs: [.x86_64, .x86_32],
                bootModes: [.uefi, .legacy]
            ),
            ImageSupportInfo(
                title: "Windows Server 2025",
                archs: [.x86_64],
                bootModes: [.uefi, .legacy]
            ),
            ImageSupportInfo(
                title: "Windows Server 2022",
                archs: [.x86_64],
                bootModes: [.uefi, .legacy]
            ),
            ImageSupportInfo(
                title: "Windows Server 2019",
                archs: [.x86_64],
                bootModes: [.uefi, .legacy]
            ),
            ImageSupportInfo(
                title: "Windows Server 2016",
                archs: [.x86_64],
                bootModes: [.uefi, .legacy]
            ),
            ImageSupportInfo(
                title: "Windows Server 2012 (R1/R2)",
                archs: [.x86_64],
                bootModes: [.uefi, .legacy]
            )
        ]
    }
}
