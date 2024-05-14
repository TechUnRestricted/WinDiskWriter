//
//  CommandLineResult.swift
//  WinDiskWriter
//
//  Created by Macintosh on 14.05.2024.
//

import Foundation

struct CommandLineResult {
    let standardData: Data
    let errorData: Data
    let terminationStatus: Int32
}
