//
//  AppRelauncherError.swift
//  WinDiskWriter
//
//  Created by Macintosh on 13.05.2024.
//

import Foundation

enum AppRelauncherError: LocalizedError {
    case argumentsListIsEmpty
    case badStructureInArguments
    case cantCreateAuthorizationReference
    case authorizationError(AuthorizationError)

    var errorDescription: String? {
        switch self {
        case .argumentsListIsEmpty:
            return "Application arguments list is empty"
        case .badStructureInArguments:
            return "Application arguments have a bad structure"
        case .authorizationError(let authError):
            return authError.rawValue
        case .cantCreateAuthorizationReference:
            return "Can't create an Authorization reference"
        }
    }
}
