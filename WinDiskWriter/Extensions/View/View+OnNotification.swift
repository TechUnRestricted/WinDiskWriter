//
//  View+OnNotification.swift
//  WinDiskWriter
//
//  Created by Macintosh on 15.12.2024.
//

import SwiftUI

extension View {
    /// Adds an `onReceive` handler for a specific notification.
    /// - Parameters:
    ///   - name: The `Notification.Name` to observe.
    ///   - perform: A closure to execute when the notification is received.
    /// - Returns: A modified `View` with the notification observer.
    func onNotification(_ name: Notification.Name, perform: @escaping () -> Void) -> some View {
        self.onReceive(NotificationCenter.default.publisher(for: name)) { _ in
            perform()
        }
    }
}
