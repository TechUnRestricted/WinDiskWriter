//
//  AppRelauncher.swift
//  WinDiskWriter
//
//  Created by Macintosh on 28.04.2024.
//

import Foundation
import AppKit

private enum Constants {
    static let openExecutable: String = "/usr/bin/open"
}

enum AppRelauncher {
    static func restartApp(withElevatedPermissions requiresRoot: Bool) async throws {
        guard let executablePath = ProcessInfo.processInfo.arguments.first else {
            throw AppRelauncherError.argumentsListIsEmpty
        }
        
        guard FileManager.default.fileExists(atPath: executablePath) else {
            throw AppRelauncherError.badStructureInArguments
        }
        
        guard requiresRoot else {
            try await CommandLine.execute(
                executablePath: Constants.openExecutable,
                arguments: ["-n", "-a", executablePath]
            )
            
            await NSApp.terminate(nil)
            return
        }
        
        var authorizationRef: AuthorizationRef?
        let authFlags: AuthorizationFlags = [.preAuthorize]
        
        // Add error handling for AuthorizationCreate
        let status = AuthorizationCreate(nil, nil, authFlags, &authorizationRef)
        guard status == errAuthorizationSuccess else {
            throw AppRelauncherError.authorizationError(authorizationError(from: status) ?? .internalError)
        }
        
        guard let authorizationRef else {
            throw AppRelauncherError.authorizationError(.invalidRef)
        }
        
        var executionStatus: OSStatus = errAuthorizationInternal
        
        executablePath.withCString { charExecutablePath in
            executionStatus = ExecuteWithPrivileges(authorizationRef, charExecutablePath, nil)
        }
        
        // Clean up the authorization reference
        defer {
            AuthorizationFree(authorizationRef, [])
        }
        
        if let authorizationError = AppRelauncher.authorizationError(from: executionStatus) {
            throw AppRelauncherError.authorizationError(authorizationError)
        }
        
        await NSApp.terminate(nil)
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
