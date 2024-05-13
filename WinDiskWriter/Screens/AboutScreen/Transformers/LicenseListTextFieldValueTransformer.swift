//
//  LicenseListTextFieldValueTransformer.swift
//  WinDiskWriter
//
//  Created by Macintosh on 13.05.2024.
//

import Cocoa

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

        var documentAttributedStringBuilder = AttributedStringBuilder()

        let briefInfoPadding: CGFloat = 10

        for (licenseFileName, licenseFileText) in licensePairs {
            guard let licenseFileName = licenseFileName as? String,
                  let licenseFileText = licenseFileText as? String else {
                      continue
                  }

            let briefInfoAttributedStringBuilder: AttributedStringBuilder = {
                let baseTextAttributedStringBuilder = AttributedStringBuilder(
                    string: "License File: "
                )
                    .weight(6)


                let licenseFileNameAttributedStringBuilder = AttributedStringBuilder(
                    string: licenseFileName + "\n"
                )
                    .weight(4)
                    .italic()

                let briefInfoAttributedStringBuilder = (baseTextAttributedStringBuilder + licenseFileNameAttributedStringBuilder)
                    .horizontalAlignment(.center)
                    .padding(
                        left: briefInfoPadding,
                        right: briefInfoPadding,
                        top: briefInfoPadding,
                        bottom: briefInfoPadding
                    )

                return briefInfoAttributedStringBuilder
            }()

            let licenceFileTextAttributedStringBuilder = AttributedStringBuilder(
                string: licenseFileText + "\n"
            )
                .weight(5)

            let singleLicenseAttributedStringBuilder = (briefInfoAttributedStringBuilder + licenceFileTextAttributedStringBuilder)

            documentAttributedStringBuilder += singleLicenseAttributedStringBuilder
        }

        documentAttributedStringBuilder.color(.labelColor)

        return documentAttributedStringBuilder.build()
    }
}
