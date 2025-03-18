//
//  UpdateCommand.swift
//  cradle
//
//  Created by trickart on 2025/03/06.
//

import ArgumentParser
import CradleKit
import CryptoKit
import Foundation
import Yams

struct UpdateCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "update",
        abstract: "Update binaries."
    )

    func run() async throws {
        try await update()
    }

    func update(fileSystem: some FileSystem = FileManager.default) async throws {
        let cradleFilePath = fileSystem.currentDirectoryPath + "/Cradlefile"
        guard fileSystem.fileExists(atPath: cradleFilePath, isDirectory: nil) else {
            print("Cradlefile not found.")
            return
        }
        let cradleFileData = try Data(contentsOf: URL(filePath: cradleFilePath))
        let cradleFile = try YAMLDecoder().decode(Cradlefile.self, from: cradleFileData)
        let checksum = SHA256.hashString(data: cradleFileData)

        let cradle = Cradle(cradleFile: cradleFile, cradleFileChecksum: checksum)
        try await cradle.update(executor: SystemCommandExecutor(), fileSystem: fileSystem, httpSession: URLSession.shared)

        print("update complete!")
    }
}
