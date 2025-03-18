//
//  MockCommandExecutor.swift
//  cradle
//
//  Created by trickart on 2025/03/23.
//

@testable import CradleKit
import Foundation

struct MockCommandExecutor: CommandExecutor {
    var runClosure: ((URL, [String]) -> Data?)?

    func run(command: URL, arguments: [String]) throws -> Data? {
        runClosure?(command, arguments)
    }
}
