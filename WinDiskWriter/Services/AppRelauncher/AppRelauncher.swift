//
//  AppRelauncher.swift
//  WinDiskWriter
//
//  Created by Macintosh on 28.04.2024.
//

import Foundation
import AppKit

class AppRelauncher {
    private enum Constants {
        static let openExecutable: String = "/usr/bin/open"
    }

    private init() { }

    static func restartApp(withElevatedPermissions requiresRoot: Bool) throws {
        guard let executablePath = ProcessInfo.processInfo.arguments.first else {
            throw AppRelauncherError.argumentsListIsEmpty
        }

        guard FileManager.default.fileExists(atPath: executablePath) else {
            throw AppRelauncherError.badStructureInArguments
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
            throw AppRelauncherError.authorizationError(authorizationError)
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
