//
//  LicenseListTextFieldValueTransformer.swift
//  WinDiskWriter
//
//  Created by Macintosh on 13.05.2024.
//

import Foundation

extension NSValueTransformerName {
    static let licenseListTextFieldValueTransformerName = NSValueTransformerName(rawValue: LicenseListTextFieldValueTransformer.className())
}

class LicenseListTextFieldValueTransformer: ValueTransformer {
    override class func transformedValueClass() -> AnyClass {
        return NSString.self
    }

    override class func allowsReverseTransformation() -> Bool {
        return false
    }

    override func transformedValue(_ value: Any?) -> Any? {
        guard let licensePairs = value as? NSDictionary else {
            return nil
        }

        let documentAttributedString = NSMutableAttributedString()

        for (licenseFileName, licenseFileText) in licensePairs {
            guard let licenseFileName = licenseFileName as? String,
                  let licenseFileText = licenseFileText as? String else {
                      continue
                  }

            let builtSingleLicenseAttributedString = NSMutableAttributedString()

            let briefInfoAttributedString: NSAttributedString = {
                let baseTextAttributedString = AttributedStringBuilder(
                    string: "License File: "
                )
                    .weight(6)
                    .build()

                let licenseFileNameAttributedString = AttributedStringBuilder(
                    string: licenseFileName
                )
                    .weight(4)
                    .italic()
                    .build()

                let briefInfoAttributedString = NSMutableAttributedString()
                briefInfoAttributedString.append(baseTextAttributedString)
                briefInfoAttributedString.append(licenseFileNameAttributedString)

                return briefInfoAttributedString
            }()

            let licenceFileTextAttributedString = AttributedStringBuilder(
                string: licenseFileText + "\n"
            )
                .weight(5)
                .build()

            builtSingleLicenseAttributedString.append(briefInfoAttributedString)
            builtSingleLicenseAttributedString.append(licenceFileTextAttributedString)

            documentAttributedString.append(builtSingleLicenseAttributedString)
        }

        return documentAttributedString
    }
}
