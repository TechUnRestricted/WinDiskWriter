//
//  WimlibWrapper.swift
//  WinDiskWriter
//
//  Created by Macintosh on 07.07.2024.
//

import Foundation

fileprivate extension Int32 {
    var asWimlibReturnCode: wimlib_error_code {
        return wimlib_error_code(UInt32(self))
    }
}

// MARK: - Wrapper Main Components
final class WimlibWrapper {
    private var currentWIM: UnsafeMutablePointer<WIMStruct>?
    private let wimURL: URL

    var imagesCount: Int32 {
        guard let currentWIM = currentWIM else {
            return 0
        }

        return Int32(currentWIM.pointee.hdr.image_count)
    }

    init?(with wimURL: URL) {
        self.wimURL = wimURL

        let wimPath: String = wimURL.path
        let openFlags: Int32 = 0

        let wimOpenStatus = wimlib_open_wim(wimPath, openFlags, &currentWIM).asWimlibReturnCode

        if wimOpenStatus != WIMLIB_ERR_SUCCESS {
            return nil
        }
    }

    deinit {
        if let currentWIM = currentWIM {
            wimlib_free(currentWIM)
        }
    }

    func applyChanges() -> Bool {
        guard let currentWIM = currentWIM else {
            return false
        }

        let writeFlags: Int32 = 0
        let numberOfThreads: UInt32 = 1

        let result = wimlib_overwrite(currentWIM, writeFlags, numberOfThreads).asWimlibReturnCode

        return result == WIMLIB_ERR_SUCCESS
    }
}

// MARK: - Files Manipulation
extension WimlibWrapper {
    func extractFiles(_ files: [String], to destination: String, fromImageIndex index: Int32) -> Bool {
        guard let currentWIM = currentWIM else {
            return false
        }

        var wimlibResult: wimlib_error_code = WIMLIB_ERR_INVALID_PARAM

        files.charUnsafePointerArray { charPointerArray in
            let result = wimlib_extract_paths(
                currentWIM,
                index,
                destination,
                charPointerArray,
                files.count,
                WIMLIB_EXTRACT_FLAG_NO_PRESERVE_DIR_STRUCTURE
            )

            wimlibResult = result.asWimlibReturnCode
        }

        return wimlibResult == WIMLIB_ERR_SUCCESS
    }
}

// MARK: - Image Property Processor
extension WimlibWrapper {
    func propertyValue(forKey key: String, imageIndex: Int32) -> String? {
        guard let currentWIM = currentWIM else {
            return nil
        }

        guard let value = wimlib_get_image_property(currentWIM, imageIndex, key) else {
            return nil
        }

        return String(cString: value)
    }

    func setPropertyValue(_ value: String, forKey key: String, imageIndex: Int32) -> WimlibWrapperResult {
        guard let currentWIM = currentWIM else {
            return .failure
        }

        guard let currentValue = propertyValue(forKey: key, imageIndex: imageIndex), currentValue != value else {
            return .skipped
        }

        let result = wimlib_set_image_property(currentWIM, imageIndex, key, value).asWimlibReturnCode

        return result == WIMLIB_ERR_SUCCESS ? .success : .failure
    }

    func setPropertyValueForAllImages(_ value: String, forKey key: String) -> WimlibWrapperResult {
        var requiresOverwriting: Bool = false

        for index in 1...imagesCount {
            let result = setPropertyValue(value, forKey: key, imageIndex: index)
            switch result {
            case .success:
                requiresOverwriting = true
            case .failure:
                return .failure
            case .skipped:
                continue
            }
        }

        return requiresOverwriting ? .success : .skipped
    }
}
