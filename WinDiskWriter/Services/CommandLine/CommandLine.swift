//
//  CommandLine.swift
//  WinDiskWriter
//
//  Created by Macintosh on 28.04.2024.
//

import Foundation

class CommandLine {
    private init() { }

    @discardableResult
    static func execute(executable: String, arguments: [String]? = nil) throws -> CommandLineResult {
        let task = Process()

        let standardPipe = Pipe()
        task.standardOutput = standardPipe

        let errorPipe = Pipe()
        task.standardError = errorPipe

        task.launchPath = executable
        task.arguments = arguments

        if let exception = LegacyExceptionHandler.catchException({
            task.launch()
            task.waitUntilExit()
        }) {
            throw CommandLineError.objectiveCException(errorString: exception.reason)
        }

        let standardOutputData = standardPipe.fileHandleForReading.readDataToEndOfFile()
        let standardErrorData = errorPipe.fileHandleForReading.readDataToEndOfFile()

        let commandLineResult = CommandLineResult(
            standardData: standardOutputData,
            errorData: standardErrorData,
            terminationStatus: task.terminationStatus
        )

        return commandLineResult
    }
}