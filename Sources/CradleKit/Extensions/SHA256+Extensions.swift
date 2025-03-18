//
//  SHA256+Extensions.swift
//  cradle
//
//  Created by trickart on 2025/03/06.
//

import CryptoKit
import Foundation

extension SHA256 {
    public static func hashString(data: some DataProtocol) -> String {
        hash(data: data)
            .map {String(format: "%02hhx", $0) }
            .joined()
    }
}
