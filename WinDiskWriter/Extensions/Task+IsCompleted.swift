//
//  Task+Completion.swift
//  WinDiskWriter
//
//  Created by Macintosh on 26.01.2025.
//

import SwiftUI

extension Task where Failure == Error {
    /// Creates and runs a Task, updating the provided `isCompleted` binding
    /// once the task finishes (success or error).
    ///
    /// - Parameters:
    ///   - isCompleted: A Binding that will be set to `false` when the task starts
    ///                  and set to `true` when the task finishes.
    ///   - priority: An optional TaskPriority for the task.
    ///   - operation: The asynchronous operation to perform.
    /// - Returns: A newly created Task instance.
    @discardableResult
    static func runWithCompletion(
        _ isCompleted: Binding<Bool>,
        priority: TaskPriority? = nil,
        operation: @escaping @Sendable () async throws -> Success
    ) -> Task<Success, Failure> {
        
        // Indicate the work has just started.
        isCompleted.wrappedValue = false
        
        return Task(priority: priority) {
            defer {
                // Mark the completion once the task finishes,
                // whether it succeeds or throws an error.
                isCompleted.wrappedValue = true
            }
            return try await operation()
        }
    }
}
