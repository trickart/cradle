//
//  CradlefileTests.swift
//  cradle
//
//  Created by trickart on 2025/03/11.
//

@testable import CradleKit
import Testing
import Yams

struct CradlefileTests {
    @Test
    func decode() throws {
        let yaml = """
cradlePath: ./cradle
github:
- reference: realm/SwiftLint
  tag: 0.58.2
- reference: SwiftGen/SwiftGen
licenseFileWriteOut: true
""".data(using: .utf8)!

        let cradleFile = try YAMLDecoder().decode(Cradlefile.self, from: yaml)

        #expect(cradleFile.cradlePath == "./cradle")

        #expect(cradleFile.github.first?.reference == "realm/SwiftLint")
        #expect(cradleFile.github.first?.tag == "0.58.2")
        #expect(cradleFile.github.first?.releaseURL.absoluteString == "https://api.github.com/repos/realm/SwiftLint/releases/tags/0.58.2")

        #expect(cradleFile.github.last?.reference == "SwiftGen/SwiftGen")
        #expect(cradleFile.github.last?.tag == nil)
        #expect(cradleFile.github.last?.releaseURL.absoluteString == "https://api.github.com/repos/SwiftGen/SwiftGen/releases/latest")

        #expect(cradleFile.licenseFileWriteOut == true)
    }
}
