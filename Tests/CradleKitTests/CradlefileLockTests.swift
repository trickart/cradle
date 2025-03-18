//
//  CradlefileLockTests.swift
//  cradle
//
//  Created by trickart on 2025/03/11.
//

@testable import CradleKit
import Foundation
import Testing

struct CradlefileLockTests {
    @Test
    func decode() throws {
        let json =  """
{
  "cradlePath" : ".\\/cradle",
  "github" : [
    {
      "reference" : "realm\\/SwiftLint",
      "tag" : "0.58.2",
      "url" : "https:\\/\\/github.com\\/realm\\/SwiftLint\\/releases\\/download\\/0.58.2\\/SwiftLintBinary.artifactbundle.zip"
    },
    {
      "reference" : "SwiftGen\\/SwiftGen",
      "tag" : "6.6.3",
      "url" : "https:\\/\\/github.com\\/SwiftGen\\/SwiftGen\\/releases\\/download\\/6.6.3\\/swiftgen-6.6.3.artifactbundle.zip"
    }
  ],
  "sha256" : "b82e7428145307fb94076d467116bfc4be97075893d901933bcd78d062eddea1"
}
""".data(using: .utf8)!

        let lockFile = try JSONDecoder().decode(CradlefileLock.self, from: json)

        #expect(lockFile.cradlePath == "./cradle")

        #expect(lockFile.github.first?.reference == "realm/SwiftLint")
        #expect(lockFile.github.first?.tag == "0.58.2")
        #expect(lockFile.github.first?.url.absoluteString == "https://github.com/realm/SwiftLint/releases/download/0.58.2/SwiftLintBinary.artifactbundle.zip")

        #expect(lockFile.github.last?.reference == "SwiftGen/SwiftGen")
        #expect(lockFile.github.last?.tag == "6.6.3")
        #expect(lockFile.github.last?.url.absoluteString == "https://github.com/SwiftGen/SwiftGen/releases/download/6.6.3/swiftgen-6.6.3.artifactbundle.zip")

        #expect(lockFile.sha256 == "b82e7428145307fb94076d467116bfc4be97075893d901933bcd78d062eddea1")
    }
}
