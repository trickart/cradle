//
//  Test.swift
//  cradle
//
//  Created by trickart on 2025/03/07.
//

@testable import CradleKit
import Foundation
import Testing

struct GitHubReleaseTests {
    static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    @Test
    func decode() async throws {
        let jsonURL = Bundle.module.url(forResource: "LicensePlistsMerger", withExtension: "json")!
        let data = try Data(contentsOf: jsonURL)

        let release = try Self.decoder.decode(GitHubRelease.self, from: data)

        #expect(release.artifactBundleURL?.absoluteString == "https://github.com/ubiregiinc/LicensePlistsMerger/releases/download/0.2.0/license-plists-merger-macos.artifactbundle.zip")
        #expect(release.tagName == "0.2.0")
    }
}
