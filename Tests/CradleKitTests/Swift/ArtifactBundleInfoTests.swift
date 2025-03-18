//
//  ArtifactBundleInfoTests.swift
//  cradle
//
//  Created by trickart on 2025/03/11.
//

@testable import CradleKit
import Foundation
import Testing

struct ArtifactBundleInfoTests {
    @Test
    func decode() throws {
        let json = """
{
  "schemaVersion": "1.0",
  "artifacts": {
    "dummy": {
      "version": "0.0.1",
      "type": "executable",
      "variants": [
        {
          "path": "dummy-0.0.1-macos/bin/dummy",
          "supportedTriples": [
            "x86_64-apple-macosx",
            "arm64-apple-macosx"
          ]
        }
      ]
    }
  }
}
""".data(using: .utf8)!

        let info = try JSONDecoder().decode(ArtifactBundleInfo.self, from: json)

        let dummy = info.artifacts["dummy"]
        #expect(dummy != nil)

        #expect(dummy?.variants.count == 1)

        #expect(dummy?.variants.first?.path == "dummy-0.0.1-macos/bin/dummy")

        #expect(dummy?.variants.first?.supportedTriples.count == 2)
        #expect(dummy?.variants.first?.supportedTriples.first == "x86_64-apple-macosx")
        #expect(dummy?.variants.first?.supportedTriples.last == "arm64-apple-macosx")
    }
}
