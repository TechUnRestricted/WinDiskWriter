//
//  PartitionScheme.swift
//  WinDiskWriter
//
//  Created by Macintosh on 28.04.2024.
//

import Foundation

enum PartitonScheme: Int, Hashable {
    case MBR = 0
    case GPT = 1
}

extension PartitonScheme {
    var parameterRepresentation: String {
        switch self {
        case .MBR:
            return "MBR"
        case .GPT:
            return "GPT"
        }
    }
}
