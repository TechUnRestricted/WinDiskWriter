//
//  URL+FormattedFileSize.swift
//  WinDiskWriter
//
//  Created by Macintosh on 22.12.2024.
//

import Foundation

extension URL {
    /// Returns the file size of the URL in a formatted human-readable string.
    /// - Returns: A formatted string representing the file size, or `nil` if the file size couldn't be determined.
    func formattedFileSize() -> String? {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: self.path)
            
            guard let size = attributes[.size] as? Int64 else {
                return nil
            }
            
            let formatter = ByteCountFormatter()
            formatter.countStyle = .file
            
            return formatter.string(fromByteCount: size)
        } catch {
            print("Error retrieving file size for \(self.path): \(error.localizedDescription)")
        }
        
        return nil
    }
}
