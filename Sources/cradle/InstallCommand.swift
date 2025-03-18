//
//  InstallCommand.swift
//  cradle
//
//  Created by trickart on 2025/03/05.
//

import ArgumentParser
import CradleKit
import CryptoKit
import Foundation
import Yams

struct InstallCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "install",
        abstract: "Install binaries."
    )

    static let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    func run() async throws {
        try await install()
    }

    func install(fileSystem: some FileSystem = FileManager.default) async throws {
        let cradleFilePath = fileSystem.currentDirectoryPath + "/Cradlefile"

        guard fileSystem.fileExists(atPath: cradleFilePath, isDirectory: nil) else {
            print("Cradlefile not found.")
            return
        }
        let cradleFileData = try Data(contentsOf: URL(filePath: cradleFilePath))
        let cradleFile = try YAMLDecoder().decode(Cradlefile.self, from: cradleFileData)
        let checksum = SHA256.hashString(data: cradleFileData)

        let lockFilePath = cradleFile.cradlePath + "/Cradlefile.lock.json"

        var lockFile: CradlefileLock?
        if fileSystem.fileExists(atPath: lockFilePath, isDirectory: nil) {
            let data = try Data(contentsOf: URL(filePath: lockFilePath))
            lockFile = try Self.jsonDecoder.decode(CradlefileLock.self, from: data)
        }

        let cradle = Cradle(cradleFile: cradleFile, cradleFileChecksum: checksum, lockFile: lockFile)
        try await cradle.installOrUpdate(executor: SystemCommandExecutor(), fileSystem: fileSystem, httpSession: URLSession.shared)
    }
}
