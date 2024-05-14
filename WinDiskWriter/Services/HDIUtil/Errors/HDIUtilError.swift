//
//  HDIUtilError.swift
//  WinDiskWriter
//
//  Created by Macintosh on 14.05.2024.
//

import Foundation

enum HDIUtilError: LocalizedError {
    case systemEntitiesNotFound
    case systemEntitiesIsEmpty
    case systemEntitiesCountMoreThanOne

    var errorDescription: String? {
        switch self {
        case .systemEntitiesNotFound:
            return "System entities could not be found in the decoded property list"
        case .systemEntitiesIsEmpty:
            return "The 'system-entities' array is empty"
        case .systemEntitiesCountMoreThanOne:
            return "The 'system-entities' array contains more than one entry"
        }
    }
}
