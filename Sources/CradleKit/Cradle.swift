//
//  Cradle.swift
//  cradle
//
//  Created by trickart on 2025/03/06.
//

import Foundation
import ZIPFoundation

public struct Cradle {
    static let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    var cradleFile: Cradlefile
    var cradleFileChecksum: String
    var lockFile: CradlefileLock?

    public init(cradleFile: Cradlefile, cradleFileChecksum: String, lockFile: CradlefileLock? = nil) {
        self.cradleFile = cradleFile
        self.cradleFileChecksum = cradleFileChecksum
        self.lockFile = lockFile
    }

    public func installOrUpdate(executor: some CommandExecutor,
                                fileSystem: some FileSystem,
                                httpSession: some HTTPSession) async throws {
        switch Self.detectInstructionType(lockFile: lockFile, checksum: cradleFileChecksum) {
        case .install(let lockFile):
            try await install(lockFile: lockFile, executor: executor, fileSystem: fileSystem, httpSession: httpSession)
        case .update:
            try await update(executor: executor, fileSystem: fileSystem, httpSession: httpSession)
        }
    }

    func install(lockFile: CradlefileLock,
                 executor: some CommandExecutor,
                 fileSystem: some FileSystem,
                 httpSession: some HTTPSession) async throws {
        print("install from Cradlefile.lock.json")

        let triple = try TripleDetector(swiftPath: .full("/usr/bin/swift"), executor: executor).detect()

        var binaries: [String: Data] = [:]
        var licenses: [String: [String: Data]] = [:]
        for reference in lockFile.github {
            print("download: \(reference.url)")
            let artifactBundleData = try await httpSession.dataOnly(from: reference.url)
            let archive = try Archive(data: artifactBundleData, accessMode: .read)
            try binaries.merge(Self.supportedBinaries(archive: archive, url: reference.url, triple: triple)) { $1 } // second win

            if lockFile.licenseFileWriteOut == true {
                let files = try Self.licenseFiles(archive: archive)

                if !files.isEmpty {
                    guard let rootPath = archive.min(by: { $0.path.count < $1.path.count })?.path else { throw CradleError.emptyArtifactBundle(reference.url)}
                    let name = rootPath.deletingPathExtension()

                    licenses[name] = files
                }
            }
        }

        try fileSystem.writeBinaries(cradlePath: lockFile.cradlePath, binaries: binaries)

        if lockFile.licenseFileWriteOut == true && !licenses.isEmpty {
            try fileSystem.writeLicenseFiles(cradlePath: lockFile.cradlePath, licenses: licenses)
        }
    }

    public func update(executor: some CommandExecutor,
                       fileSystem: some FileSystem,
                       httpSession: some HTTPSession) async throws {
        print("install from Cradlefile")

        let triple = try TripleDetector(swiftPath: .full("/usr/bin/swift"), executor: executor).detect()

        var intermediates: [IntermediateGitHubReference] = []
        var licenses: [String: [String: Data]] = [:]
        for reference in cradleFile.github {
            let releaseData =  try await httpSession.dataOnly(from: reference.releaseURL)
            let release = try Self.jsonDecoder.decode(GitHubRelease.self, from: releaseData)
            guard let url = release.artifactBundleURL else { throw CradleError.notHaveArtifactBundle(reference.releaseURL) }

            print("download: \(url)")
            let artifactBundleData = try await httpSession.dataOnly(from: url)
            let archive = try Archive(data: artifactBundleData, accessMode: .read)
            let binaries = try Self.supportedBinaries(archive: archive, url: url, triple: triple)

            intermediates.append(IntermediateGitHubReference(reference: reference.reference, tag: release.tagName, url: url, binaries: binaries))

            if cradleFile.licenseFileWriteOut == true {
                let files = try Self.licenseFiles(archive: archive)

                if !files.isEmpty {
                    guard let rootPath = archive.min(by: { $0.path.count < $1.path.count })?.path else { throw CradleError.emptyArtifactBundle(url)}
                    let name = rootPath.deletingPathExtension()

                    licenses[name] = files
                }
            }

            if cradleFile.licenseFileWriteOut == true && !licenses.isEmpty {
                try fileSystem.writeLicenseFiles(cradlePath: cradleFile.cradlePath, licenses: licenses)
            }
        }

        let binaries = intermediates.reduce(into: [String: Data]()) { reduced, intermediate in
            reduced.merge(intermediate.binaries) { $1 }
        }
        try fileSystem.writeBinaries(cradlePath: cradleFile.cradlePath, binaries: binaries)

        if cradleFile.licenseFileWriteOut == true && !licenses.isEmpty {
            try fileSystem.writeLicenseFiles(cradlePath: cradleFile.cradlePath, licenses: licenses)
        }

        try fileSystem.writeLockFile(cradlePath: cradleFile.cradlePath,
                                     checksum: cradleFileChecksum,
                                     intermediates: intermediates,
                                     licenseFileWriteOut: cradleFile.licenseFileWriteOut)
    }
}

extension Cradle {
    enum InstructionType: Equatable {
        case install(CradlefileLock)
        case update
    }

    static func detectInstructionType(lockFile: CradlefileLock?, checksum: String) -> InstructionType {
        if let lockFile {
            if lockFile.sha256 == checksum {
                return .install(lockFile)
            } else {
                return .update
            }
        } else {
            return .update
        }
    }

    static func supportedBinaries(archive: Archive, url: URL, triple: String) throws -> [String: Data] {
        guard let rootPath = archive.min(by: { $0.path.count < $1.path.count })?.path else { throw CradleError.emptyArtifactBundle(url) }
        guard let infoEntry = archive.first(where: { $0.path.hasSuffix("info.json") }) else { throw CradleError.notHaveInfoJson(url) }
        var infoData = Data()
        _ = try archive.extract(infoEntry) { infoData.append($0) }
        let info = try Self.jsonDecoder.decode(ArtifactBundleInfo.self, from: infoData)

        let paths = info.artifacts
            .flatMap(\.value.variants)
            .filter { $0.supportedTriples.contains(triple) }
            .map(\.path)

        return try archive
            .filter { paths.contains(String($0.path.dropFirst(rootPath.count))) }
            .reduce(into: [String: Data]()) { dictionary, entity in
                var data = Data()
                _ = try archive.extract(entity) { data.append($0) }
                dictionary[entity.path.lastPathComponent] = data
            }
    }

    static func licenseFiles(archive: Archive) throws -> [String: Data] {
        try archive
            .filter { Self.isLicense($0.path) }
            .reduce(into: [String: Data]()) { dictionary, entity in
                var data = Data()
                _ = try archive.extract(entity) { data.append($0) }
                dictionary[entity.path.lastPathComponent] = data
            }
    }

    static func isLicense(_ path: String) -> Bool {
        let name = path.lastPathComponent.lowercased()
        return name.hasPrefix("license") || name.hasPrefix("licence") // British spelling
    }
}

private extension String {
    var lastPathComponent: String {
        let splitted = split(separator: "/")
        return String(splitted[splitted.count - 1])
    }

    func deletingPathExtension() -> String {
        let splitted = split(separator: ".")
        let parts = splitted[0..<(splitted.count - 1)]
        return parts.joined(separator: ".")
    }
}
