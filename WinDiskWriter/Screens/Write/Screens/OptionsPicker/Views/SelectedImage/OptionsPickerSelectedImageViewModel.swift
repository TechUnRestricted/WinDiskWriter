//
//  OptionsPickerSelectedImageViewModel.swift
//  WinDiskWriter
//
//  Created by Macintosh on 25.12.2024.
//

import SwiftUI

class OptionsPickerSelectedImageViewModel: ObservableObject {
    private let imageInfo: PickedImageInfo
    
    private var mountPointURL: URL {
        URL(fileURLWithPath: imageInfo.attachEntity.mountPoint)
    }
    
    var fileIcon: NSImage {        
        return NSWorkspace.shared.icon(forFile: imageInfo.imageFileURL.path(percentEncoded: false))
    }
    
    var directoryName: String {
        imageInfo.imageFileURL.lastPathComponent
    }
    
    var mountPointLastComponent: String {
        mountPointURL.lastPathComponent
    }
    
    init(imageInfo: PickedImageInfo) {
        self.imageInfo = imageInfo
    }
}
