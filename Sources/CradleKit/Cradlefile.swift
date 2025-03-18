//
//  Cradlefile.swift
//  cradle
//
//  Created by trickart on 2025/03/04.
//

import Foundation

public struct Cradlefile: Decodable {
    struct GitHubReference: Decodable {
        var reference: String
        var tag: String?
    }

    public var cradlePath: String
    var github: [GitHubReference]
    var licenseFileWriteOut: Bool?
}

extension Cradlefile.GitHubReference {
    var releaseURL: URL {
        if let tag {
            return URL(string: "https://api.github.com/repos/\(reference)/releases/tags/\(tag)")!
        } else {
            return URL(string: "https://api.github.com/repos/\(reference)/releases/latest")!
        }
    }
}
