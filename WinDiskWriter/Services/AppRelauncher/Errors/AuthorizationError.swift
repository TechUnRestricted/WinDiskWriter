//
//  AuthorizationError.swift
//  WinDiskWriter
//
//  Created by Macintosh on 13.05.2024.
//

import Foundation

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
