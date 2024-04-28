//
//  AppRelauncher.swift
//  WinDiskWriter
//
//  Created by Macintosh on 28.04.2024.
//

import Foundation
import AppKit

enum AppRelaunchError: Error {
    case argumentsListIsEmpty
    case badStructureInArguments
    case cantCreateAuthorizationReference
    case authorizationError(AuthorizationError)
}

extension AppRelaunchError: LocalizedError {
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

enum AuthorizationError: String {
    case badAddress = "The requested socket address is invalid (must be 0-1023 inclusive)"
    case canceled = "The authorization was canceled by the user"
    case denied = "The authorization was denied"
    case externalizeNotAllowed = "The Security Server denied externalization of the authorization reference"
    case interactionNotAllowed = "The authorization was denied since no user interaction was possible"
    case internalError = "An unrecognized internal error occurred"
    case internalizeNotAllowed = "The Security Server denied internalization of the authorization reference"
    case invalidFlags = "The provided option flag(s) are invalid for this authorization operation"
    case invalidPointer = "The authorizedRights parameter is invalid"
    case invalidRef = "The authorization parameter is invalid"
    case invalidSet = "The set parameter of authorization is invalid"
    case invalidTag = "The authorization tag is invalid"
    case toolEnvironmentError = "The attempt to execute the authorization tool failed to return a success or an error code"
    case toolExecuteFailure = "The authorization tool failed to execute"
}

class AppRelauncher {
    private enum Constants {
        static let openExecutable: String = "/usr/bin/open"
    }

    private init() { }

    static func restartApp(withElevatedPermissions requiresRoot: Bool) throws {
        guard let executablePath = ProcessInfo.processInfo.arguments.first else {
            throw AppRelaunchError.argumentsListIsEmpty
        }

        guard FileManager.default.fileExists(atPath: executablePath) else {
            throw AppRelaunchError.badStructureInArguments
        }

        guard requiresRoot else {
            try CommandLine.execute(
                executable: Constants.openExecutable,
                arguments: ["-n", "-a", executablePath]
            )

            exit(EXIT_SUCCESS)
        }

        var authorizationRef: AuthorizationRef?
        let authFlags: AuthorizationFlags = [.preAuthorize]
        AuthorizationCreate(.none, .none, authFlags, &authorizationRef)

        guard let authorizationRef = authorizationRef else {
            return
        }

        var executionStatus: OSStatus = errAuthorizationInternal

        executablePath.withCString { charExecutablePath in
            executionStatus = ExecuteWithPrivileges(authorizationRef, charExecutablePath, nil)
        }

        if let authorizationError = AppRelauncher.authorizationError(from: executionStatus) {
            throw AppRelaunchError.authorizationError(authorizationError)
        }

        exit(EXIT_SUCCESS)
    }

    private static func authorizationError(from status: OSStatus) -> AuthorizationError? {
        switch status {
        case errAuthorizationSuccess:
            return nil
        case errAuthorizationInvalidSet:
            return .invalidSet
        case errAuthorizationInvalidRef:
            return .invalidRef
        case errAuthorizationInvalidTag:
            return .invalidTag
        case errAuthorizationInvalidPointer:
            return .invalidPointer
        case errAuthorizationDenied:
            return .denied
        case errAuthorizationCanceled:
            return .canceled
        case errAuthorizationInteractionNotAllowed:
            return .interactionNotAllowed
        case errAuthorizationInternal:
            return .internalError
        case errAuthorizationExternalizeNotAllowed:
            return .externalizeNotAllowed
        case errAuthorizationInternalizeNotAllowed:
            return .internalizeNotAllowed
        case errAuthorizationInvalidFlags:
            return .invalidFlags
        case errAuthorizationToolExecuteFailure:
            return .toolExecuteFailure
        case errAuthorizationToolEnvironmentError:
            return .toolEnvironmentError
        case errAuthorizationBadAddress:
            return .badAddress
        default:
            return .internalError
        }
    }
}
