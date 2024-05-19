//
//  Encodable+AsJSONString.swift
//  WinDiskWriter
//
//  Created by Macintosh on 19.05.2024.
//

import Foundation

extension Encodable {
    func asJSONString() -> String {
        let encoder = JSONEncoder()

        guard let data = try? encoder.encode(self),
              let jsonString = String(data: data, encoding: .utf8) else {
                  return "{}"
              }

        return jsonString.replacingOccurrences(of: "\\", with: "")
    }
}
