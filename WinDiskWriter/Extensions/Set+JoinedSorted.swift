//
//  Set+JoinedSorted.swift
//  WinDiskWriter
//
//  Created by Macintosh on 21.12.2024.
//

import Foundation

extension Set {
    /// Returns a joined string of the set's elements, sorted by the specified criteria and separated by the specified separator.
    /// - Parameters:
    ///   - by: A closure that determines the sorting criteria. Defaults to `<`.
    ///   - separator: A string to insert between each of the joined elements. Defaults to `\","`
    ///   - transform: A closure that converts an element to a string. Defaults to `String(describing:)`.
    ///   - Returns: A joined string of the sorted elements.
    func joinedSorted(
        by areInIncreasingOrder: (Element, Element) -> Bool = { String(describing: $0) < String(describing: $1) },
        separator: String = ",",
        transform: (Element) -> String = { String(describing: $0) }
    ) -> String {
        return self.sorted(by: areInIncreasingOrder)
                   .map(transform)
                   .joined(separator: separator)
    }
}
