//
//  DiskInfo+ShortDescription.swift
//  WinDiskWriter
//
//  Created by Macintosh on 29.12.2024.
//

extension DiskInfo {
    private enum Constants {
        static let vendorFallback: String = LocalizedStringResource("Unknown Vendor").stringValue
        static let modelFallback: String = LocalizedStringResource("Unknown Model").stringValue
        static let formattedSizeFallback: String = "??.?? MB"
    }

    func shortDescription() -> String {
        let vendor = (device.vendor ?? Constants.vendorFallback).stripped()
        let model = (device.model ?? Constants.modelFallback).stripped()
        let size = media.size?.formattedSize ?? Constants.formattedSizeFallback
        let bsdName = media.bsdName
        
        return "\(vendor) \(model) [\(size)] (\(bsdName))"
    }
}
