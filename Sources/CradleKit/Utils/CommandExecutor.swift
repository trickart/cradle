//
//  CommandExecutor.swift
//  cradle
//
//  Created by trickart on 2025/03/03.
//

import Foundation

public protocol CommandExecutor {
    func run(command: URL, arguments: [String]) throws -> Data?
}

public struct SystemCommandExecutor: CommandExecutor {
    public init() {}

    public func run(command: URL, arguments: [String]) throws -> Data? {
        let process = Process()
        process.executableURL = command
        process.arguments = arguments
        let pipe = Pipe()
        process.standardOutput = pipe

        try process.run()
        process.waitUntilExit()

        return try pipe.fileHandleForReading.readToEnd()
    }
}

public enum CommandPathType {
    case full(String)
    case relative(String)
    case inPath(String)

    public func url() throws -> URL {
        switch self {
        case .full(let string):
            return URL(filePath: string)
        case .relative(let string):
            return URL(filePath: FileManager.default.currentDirectoryPath + string)
        case .inPath(let string):
            let data = try SystemCommandExecutor().run(command: URL(filePath: "/usr/bin/which"),arguments: [string])
            guard let data,
                  let output = String(data: data, encoding: .utf8) else { fatalError() }

            return URL(filePath: output.trimmingCharacters(in: .newlines))
        }
    }
}
