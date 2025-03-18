//
//  CradleTests.swift
//  cradle
//
//  Created by trickart on 2025/03/23.
//

@testable import CradleKit
import Foundation
import Testing
import ZIPFoundation

struct CradleTests {
    @Test
    func detectInstructionType() {
        #expect(Cradle.detectInstructionType(lockFile: nil, checksum: "") == .update)

        let lockFile = CradlefileLock(cradlePath: "", github: [], sha256: "")
        #expect(Cradle.detectInstructionType(lockFile: lockFile, checksum: "!") == .update)
        #expect(Cradle.detectInstructionType(lockFile: lockFile, checksum: "") == .install(lockFile))
    }

    @Test
    func supportedBinaries() throws {
        let url = Bundle.module.url(forResource: "dummy.artifactbundle", withExtension: "zip")!
        let archive = try Archive(url: url, accessMode: .read)

        let supported = try Cradle.supportedBinaries(archive: archive,
                                                     url: URL(string: "http://example.com")!,
                                                     triple: "arm64-apple-macosx")

        #expect(supported.count == 1)
        #expect(supported.first?.key == "dummy")
    }

    @Test
    func licenseFiles() throws {
        let url = Bundle.module.url(forResource: "dummy.artifactbundle", withExtension: "zip")!
        let archive = try Archive(url: url, accessMode: .read)

        let licenses = try Cradle.licenseFiles(archive: archive)

        #expect(licenses.count == 1)
        #expect(licenses.first?.key == "LICENSE")
        #expect(licenses.first?.value == "dummy license\n".data(using: .utf8))
    }

    @Test
    func install() async throws {
        let cradleFile = Cradlefile(cradlePath: "cradle", github: [.init(reference: "dummy/dummy")], licenseFileWriteOut: true)
        let lockFile = CradlefileLock(cradlePath: "cradle", github: [.init(reference: "dummy/dummy", tag: "", url: URL(string: "example.com")!)], licenseFileWriteOut: true, sha256: "")
        let cradle = Cradle(cradleFile: cradleFile, cradleFileChecksum: "", lockFile: lockFile)

        let executor = MockCommandExecutor() { _, _ in swiftPrintTargetInfo.data(using: .utf8)! }
        let fileSystem = MockFileSystem(currentDirectoryPath: "/", fileExists: [:])
        let data = try Data(contentsOf: Bundle.module.url(forResource: "dummy.artifactbundle", withExtension: "zip")!)
        let response = HTTPURLResponse(url: URL(string: "example.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        let httpSession = MockHTTPSession(outputs: ["example.com": (data, response)])

        try await cradle.install(lockFile: lockFile, executor: executor, fileSystem: fileSystem, httpSession: httpSession)

        #expect(fileSystem.wroteFiles.first == "cradle/bin/dummy")
        #expect(fileSystem.wroteFiles.last == "cradle/licenses/dummy/LICENSE")
    }
}

private let swiftPrintTargetInfo = """
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
"""
