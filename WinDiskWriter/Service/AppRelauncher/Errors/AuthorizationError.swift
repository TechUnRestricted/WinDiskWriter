//
//  AuthorizationError.swift
//  WinDiskWriter
//
//  Created by Macintosh on 13.05.2024.
//

import Foundation

enum AuthorizationError: LocalizedError {
    case badAddress
    case canceled
    case denied
    case externalizeNotAllowed
    case interactionNotAllowed
    case internalError
    case internalizeNotAllowed
    case invalidFlags
    case invalidPointer
    case invalidRef
    case invalidSet
    case invalidTag
    case toolEnvironmentError
    case toolExecuteFailure
    
    var errorDescription: String? {
        switch self {
        case .badAddress:
            return LocalizedStringResource("The requested socket address is invalid (must be 0-1023 inclusive)").stringValue
        case .canceled:
            return LocalizedStringResource("The authorization was canceled by the user").stringValue
        case .denied:
            return LocalizedStringResource("The authorization was denied").stringValue
        case .externalizeNotAllowed:
            return LocalizedStringResource("The Security Server denied externalization of the authorization reference").stringValue
        case .interactionNotAllowed:
            return LocalizedStringResource("The authorization was denied since no user interaction was possible").stringValue
        case .internalError:
            return LocalizedStringResource("An unrecognized internal error occurred").stringValue
        case .internalizeNotAllowed:
            return LocalizedStringResource("The Security Server denied internalization of the authorization reference").stringValue
        case .invalidFlags:
            return LocalizedStringResource("The provided option flag(s) are invalid for this authorization operation").stringValue
        case .invalidPointer:
            return LocalizedStringResource("The authorizedRights parameter is invalid").stringValue
        case .invalidRef:
            return LocalizedStringResource("The authorization parameter is invalid").stringValue
        case .invalidSet:
            return LocalizedStringResource("The set parameter of authorization is invalid").stringValue
        case .invalidTag:
            return LocalizedStringResource("The authorization tag is invalid").stringValue
        case .toolEnvironmentError:
            return LocalizedStringResource("The attempt to execute the authorization tool failed to return a success or an error code").stringValue
        case .toolExecuteFailure:
            return LocalizedStringResource("The authorization tool failed to execute").stringValue
        }
    }
}
