//
//  SwiftTargetInfo.swift
//  cradle
//
//  Created by trickart on 2025/03/03.
//

struct SwiftTargetInfo: Decodable {
    struct Target: Decodable {
        var unversionedTriple: String
    }

    var target: Target
}
