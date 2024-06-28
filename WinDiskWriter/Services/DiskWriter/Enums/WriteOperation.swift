//
//  WriteOperation.swift
//  WinDiskWriter
//
//  Created by Macintosh on 26.05.2024.
//

import Foundation

indirect enum WriteOperation {
    case createFolder(
        destination: URL,
        children: [WriteOperation]? = nil
    )

    case copyFile(
        source: URL,
        destination: URL,
        children: [WriteOperation]? = nil
    )
}
