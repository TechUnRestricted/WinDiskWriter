//
//  CommandLine.swift
//  WinDiskWriter
//
//  Created by Macintosh on 22.12.2024.
//

import Foundation

/// A utility class for executing shell commands asynchronously.
enum CommandLine {

    /// Executes a shell command asynchronously and returns its output.
    /// - Parameters:
    ///   - executablePath: The path to the executable binary.
    ///   - arguments: An array of arguments for the command.
    /// - Returns: The standard output from the command execution.
    /// - Throws: `CommandLineError` if the command fails.
    
    @discardableResult
    static func execute(executablePath: String, arguments: [String] = []) async throws -> String {
        guard !executablePath.isEmpty else {
            throw CommandLineError.invalidExecutablePath
        }

        return try await runProcess(executablePath: executablePath, arguments: arguments)
    }

    /// Runs the process and captures its output and errors.
    /// - Parameters:
    ///   - executablePath: The path to the executable binary.
    ///   - arguments: An array of arguments for the command.
    /// - Returns: The standard output from the process.
    /// - Throws: `CommandLineError` if the process fails.
    private static func runProcess(executablePath: String, arguments: [String]) async throws -> String {        
        return try await withCheckedThrowingContinuation { continuation in
            let process = createProcess(executablePath: executablePath, arguments: arguments)

            let outputPipe = Pipe()
            let errorPipe = Pipe()

            process.standardOutput = outputPipe
            process.standardError = errorPipe

            do {
                try process.run()
            } catch {
                continuation.resume(throwing: error)
                return
            }

            process.terminationHandler = { process in
                handleProcessTermination(process, outputPipe: outputPipe, errorPipe: errorPipe, continuation: continuation)
            }
        }
    }

    /// Creates a configured `Process` instance.
    /// - Parameters:
    ///   - executablePath: The path to the executable binary.
    ///   - arguments: An array of arguments for the command.
    /// - Returns: A configured `Process` instance.
    private static func createProcess(executablePath: String, arguments: [String]) -> Process {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executablePath)
        process.arguments = arguments
        return process
    }

    /// Handles process termination and resumes the continuation.
    /// - Parameters:
    ///   - process: The terminated process.
    ///   - outputPipe: The pipe capturing standard output.
    ///   - errorPipe: The pipe capturing standard error.
    ///   - continuation: The continuation to resume with the result.
    private static func handleProcessTermination(
        _ process: Process,
        outputPipe: Pipe,
        errorPipe: Pipe,
        continuation: CheckedContinuation<String, Error>
    ) {
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()

        let output = String(data: outputData, encoding: .utf8)?.stripped() ?? ""
        let errorOutput = String(data: errorData, encoding: .utf8)?.stripped() ?? ""

        if process.terminationStatus == 0 {
            continuation.resume(returning: output)
        } else {
            let error = CommandLineError.commandFailed(exitCode: process.terminationStatus, errorMessage: errorOutput)
            continuation.resume(throwing: error)
        }
    }
}
