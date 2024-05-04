//
//  SelectedDeviceVerifyError.swift
//  WinDiskWriter
//
//  Created by Macintosh on 03.05.2024.
//

import Foundation

enum SelectedDeviceVerifyError: Error, LocalizedError {
    case unableToRetrieveUpdatedDeviceInfo
    case appearanceTimestampDiscrepancy
    case imagePathCollidesWithDestination

    var errorDescription: String? {
        switch self {
        case .unableToRetrieveUpdatedDeviceInfo:
            return "Unable to retrieve updated device information"
        case .appearanceTimestampDiscrepancy:
            return "Discrepancy detected in device appearance timestamps"
        case .imagePathCollidesWithDestination:
            return "Image path is located on the destination device"
        }
    }
}
