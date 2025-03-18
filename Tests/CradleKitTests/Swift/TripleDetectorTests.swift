//
//  TripleDetectorTests.swift
//  cradle
//
//  Created by trickart on 2025/03/23.
//

@testable import CradleKit
import Foundation
import Testing

struct TripleDetectorTests {
    @Test
    func detect() throws {
        let executor = MockCommandExecutor() { command, arguments in
            #expect(command.absoluteString == "file:///usr/bin/swift")
            #expect(arguments == ["-print-target-info"])
            return """
{
  "compilerVersion": "Apple Swift version 6.0.2 (swiftlang-6.0.2.1.2 clang-1600.0.26.4)",
  "target": {
    "triple": "arm64-apple-macosx14.0",
    "unversionedTriple": "arm64-apple-macosx",
    "moduleTriple": "arm64-apple-macos",
    "swiftRuntimeCompatibilityVersion": "5.9",
    "compatibilityLibraries": [ ],
    "librariesRequireRPath": false
  },
  "paths": {
    "runtimeLibraryPaths": [
      "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/macosx",
      "/usr/lib/swift"
    ],
    "runtimeLibraryImportPaths": [
      "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/macosx"
    ],
    "runtimeResourcePath": "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift"
  }
}
""".data(using: .utf8)!
        }

        let detector = TripleDetector(swiftPath: .full("/usr/bin/swift"), executor: executor)

        #expect(try detector.detect() == "arm64-apple-macosx")
    }
}
