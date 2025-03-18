//
//  FileSystem.swift
//  cradle
//
//  Created by trickart on 2025/03/06.
//

import CryptoKit
import Foundation

public protocol FileSystem {
    var currentDirectoryPath: String { get }

    func setAttributes(_ attributes: [FileAttributeKey : Any], ofItemAtPath path: String) throws
    func createDirectory(atPath path: String, withIntermediateDirectories createIntermediates: Bool) throws
    func fileExists(atPath path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) -> Bool
    func createFile(atPath path: String, contents data: Data?) -> Bool

    func createDirectoryIfNeeded(path: String) throws
    func writeFile(path: String, data: Data) throws
}

extension FileManager: FileSystem {
    public func createDirectory(atPath path: String, withIntermediateDirectories createIntermediates: Bool) throws {
        try createDirectory(atPath: path, withIntermediateDirectories: createIntermediates, attributes: nil)
    }

    public func createFile(atPath path: String, contents data: Data?) -> Bool {
        createFile(atPath: path, contents: data, attributes: nil)
    }

    public func createDirectoryIfNeeded(path: String) throws {
        var isDirectory: ObjCBool = false
        let fileExists = fileExists(atPath: path, isDirectory: &isDirectory)
        if fileExists && !isDirectory.boolValue { // exists, but not directory
            throw CradleError.createDirectory(path)
        } else if !fileExists { // not exists
            try createDirectory(atPath: path, withIntermediateDirectories: true)
        } // else {} // directory exists
    }

    public func writeFile(path: String, data: Data) throws {
        let isSuccess = createFile(atPath: path, contents: nil)
        guard isSuccess else { throw CradleError.createFile(path) }

        try data.write(to: URL(filePath: path))
    }
}

// MARK: - Cradle specific
private let jsonEncoder: JSONEncoder = {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    return encoder
}()

extension FileSystem {
    func writeBinaries(cradlePath: String, binaries: [String: Data]) throws {
        let binDirectoryPath = cradlePath + "/bin/"
        try createDirectoryIfNeeded(path: binDirectoryPath)

        for binary in binaries {
            let binaryPath = binDirectoryPath + binary.key
            try writeFile(path: binaryPath, data: binary.value)
            try setAttributes([.posixPermissions: 0o755], ofItemAtPath: binaryPath)
        }
    }

    func writeLicenseFiles(cradlePath: String, licenses: [String: [String: Data]]) throws {
        let licensesDirectoryPath = cradlePath + "/licenses/"
        try createDirectoryIfNeeded(path: licensesDirectoryPath)

        for artifact in licenses {
            let artifactDirectoryPath = licensesDirectoryPath + "\(artifact.key)/"
            try createDirectoryIfNeeded(path: artifactDirectoryPath)

            for license in artifact.value {
                let licenseFilePath = artifactDirectoryPath + license.key
                try writeFile(path: licenseFilePath, data: license.value)
            }
        }
    }

    func writeLockFile(cradlePath: String,
                       checksum: String,
                       intermediates: [IntermediateGitHubReference],
                       licenseFileWriteOut: Bool?) throws {
        let lock = CradlefileLock(cradlePath: cradlePath,
                                  github: intermediates.map { CradlefileLock.GitHubReference(reference: $0.reference, tag: $0.tag, url: $0.url) },
                                  licenseFileWriteOut: licenseFileWriteOut,
                                  sha256: checksum)

        let lockFilePath = cradlePath + "/Cradlefile.lock.json"
        let data = try jsonEncoder.encode(lock)
        try writeFile(path: lockFilePath, data: data)
    }
}
