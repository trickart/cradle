//
//  CradlefileLock.swift
//  cradle
//
//  Created by trickart on 2025/03/05.
//

import CryptoKit
import Foundation

public struct CradlefileLock: Equatable, Codable {
    struct GitHubReference: Equatable, Codable {
        var reference: String
        var tag: String
        /// artifactbundle.zip's URL
        var url: URL
    }

    var cradlePath: String
    var github: [GitHubReference]
    var licenseFileWriteOut: Bool?
    /// Cradlefile's checksum
    var sha256: String
}

extension CradlefileLock {
    init(cradlePath: String, intermediates: [IntermediateGitHubReference], licenseFileWriteOut: Bool?, cradleFile: Data) {
        self.cradlePath = cradlePath
        github = intermediates.map { GitHubReference(reference: $0.reference, tag: $0.tag, url: $0.url) }
        self.licenseFileWriteOut = licenseFileWriteOut
        sha256 = SHA256.hashString(data: cradleFile)
    }
}

struct IntermediateGitHubReference {
    var reference: String
    var tag: String
    var url: URL
    var binaries: [String: Data]
}
