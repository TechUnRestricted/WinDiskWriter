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
            return LocalizedStringResource("Application arguments list is empty").stringValue
        case .badStructureInArguments:
            return LocalizedStringResource("Application arguments have a bad structure").stringValue
        case .authorizationError(let authError):
            return authError.localizedDescription
        case .cantCreateAuthorizationReference:
            return LocalizedStringResource("Can't create an Authorization reference").stringValue
        }
    }
}
