//
//  String+CharUnsafePointerArray.swift
//  WinDiskWriter
//
//  Created by Macintosh on 28.04.2024.
//

import Foundation

extension Array where Element == String {
    func charUnsafePointerArray<Result>(_ body: (UnsafePointer<UnsafePointer<Int8>?>?) throws -> Result) rethrows -> Result {
        let count = self.count
        let cArray = UnsafeMutablePointer<UnsafePointer<Int8>?>.allocate(capacity: count + 1)
        
        defer {
            for i in 0..<count {
                free(UnsafeMutablePointer(mutating: cArray[i]))
            }
            
            cArray.deallocate()
        }
        
        for (index, string) in self.enumerated() {
            cArray[index] = UnsafePointer(strdup(string))
        }
        
        // Null-termination
        cArray[count] = nil
        
        return try body(UnsafePointer(cArray))
    }
}
