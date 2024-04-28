//
//  String+CChar.swift
//  WinDiskWriter
//
//  Created by Macintosh on 28.04.2024.
//

import Foundation

extension String {
    /*
    func withCCharArray<Result>(_ body: (UnsafeMutablePointer<Int8>?) throws -> Result) rethrows -> Result {
        let cArray = strdup(self)

        defer {
            cArray?.deallocate()
        }

        return try body(cArray)
    }
     */
}

extension Array where Element == String {
    func withCCharPointerArray<Result>(_ body: (UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>?) throws -> Result) rethrows -> Result {
        let count = self.count
        let cArray = UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>.allocate(capacity: count + 1)

        defer {
            for i in 0..<count {
                cArray[i]?.deallocate()
            }

            cArray.deallocate()
        }

        for (index, string) in self.enumerated() {
            cArray[index] = strdup(string)
        }

        // Null-termination
        cArray[count] = nil

        return try body(cArray)
    }
}
