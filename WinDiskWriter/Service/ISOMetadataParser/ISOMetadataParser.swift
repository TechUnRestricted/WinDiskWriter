//
//  ISOMetadataParser.swift
//  WinDiskWriter
//
//  Created by Macintosh on 15.12.2024.
//

import Foundation

private enum Constants {
    static let magicNumber: String = "CD001"
}

final class ISOMetadataParser {
    private let fileURL: URL
    private let sectorSize = 2048

    init(fileURL: URL) {
        self.fileURL = fileURL
    }

    func parseMetadata() async throws -> ISOMetadata {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            throw ISOMetadataParserError.fileNotFound
        }

        let fileHandle: FileHandle
        let fileSize: UInt64

        do {
            fileHandle = try FileHandle(forReadingFrom: fileURL)
            let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
            fileSize = attributes[.size] as? UInt64 ?? 0
        } catch {
            throw ISOMetadataParserError.readError
        }

        defer {
            try? fileHandle.close()
        }

        // Ensure the file is large enough for a valid ISO image
        if fileSize < sectorSize * 16 {
            throw ISOMetadataParserError.invalidISOImage
        }

        // Read the Primary Volume Descriptor (sector 16, offset 2048 * 16)
        let pvdOffset = sectorSize * 16
        try fileHandle.seek(toOffset: UInt64(pvdOffset))
        guard let pvdData = try fileHandle.read(upToCount: sectorSize),
              pvdData.count == sectorSize else {
            throw ISOMetadataParserError.invalidISOImage
        }

        // Validate PVD identifier ("CD001" at byte offset 1-5)
        let identifierRange = 1..<6
        guard let identifier = String(data: pvdData.subdata(in: identifierRange), encoding: .ascii),
              identifier == Constants.magicNumber else {
            throw ISOMetadataParserError.invalidISOImage
        }

        // Parse Volume Identifier (offset 40, length 32)
        let volumeIdentifierRange = 40..<72
        let volumeIdentifier = extractString(from: pvdData, range: volumeIdentifierRange)

        // Parse System Identifier (offset 8, length 32)
        let systemIdentifierRange = 8..<40
        let systemIdentifier = extractString(from: pvdData, range: systemIdentifierRange)

        // Parse Volume Set Identifier (offset 190, length 128)
        let volumeSetIdentifierRange = 190..<318
        let volumeSetIdentifier = extractString(from: pvdData, range: volumeSetIdentifierRange)

        // Parse Publisher (offset 318, length 128)
        let publisherRange = 318..<446
        let publisher = extractString(from: pvdData, range: publisherRange)

        // Parse Creation Date (offset 813, length 17)
        let creationDateRange = 813..<830
        guard let creationDate = parseISODate(from: pvdData.subdata(in: creationDateRange)) else {
            throw ISOMetadataParserError.metadataNotFound
        }

        // Calculate capacity
        let capacity = fileSize // Total size in bytes

        // Return metadata
        return ISOMetadata(
            volumeIdentifier: volumeIdentifier,
            systemIdentifier: systemIdentifier,
            volumeSetIdentifier: volumeSetIdentifier,
            publisher: publisher,
            creationDate: creationDate,
            capacity: capacity
        )
    }

    // Helper to extract strings from the ISO data
    private func extractString(from data: Data, range: Range<Int>) -> String {
        let subdata = data.subdata(in: range)
        return String(bytes: subdata, encoding: .ascii)?.stripped() ?? ""
    }

    // Helper to parse the ISO8601-style date format used in ISO9660
    private func parseISODate(from data: Data) -> Date? {
        guard let dateString = String(data: data, encoding: .ascii), dateString.count == 17 else {
            return nil
        }

        let year = Int(dateString.prefix(4)) ?? 0
        let month = Int(dateString.dropFirst(4).prefix(2)) ?? 0
        let day = Int(dateString.dropFirst(6).prefix(2)) ?? 0
        let hour = Int(dateString.dropFirst(8).prefix(2)) ?? 0
        let minute = Int(dateString.dropFirst(10).prefix(2)) ?? 0
        let second = Int(dateString.dropFirst(12).prefix(2)) ?? 0

        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        components.second = second
        components.timeZone = TimeZone(secondsFromGMT: 0) // ISO9660 uses UTC

        return Calendar(identifier: .gregorian).date(from: components)
    }
}
