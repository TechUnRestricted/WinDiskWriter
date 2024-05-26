//
//  DiskWriterDelegate.swift
//  WinDiskWriter
//
//  Created by Macintosh on 26.05.2024.
//

import Foundation

protocol DiskWriterDelegate: AnyObject {
    func diskWriterQueueAdded(_ action: WriteActionType)
    func diskWriterWill(_ action: WriteActionType)
    func diskWriterDid(_ action: WriteActionType)
    func diskWriterFailed(_ action: WriteActionType, error: Error)
}
