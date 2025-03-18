//
//  TripleDetector.swift
//  cradle
//
//  Created by trickart on 2025/03/04.
//

import Foundation

struct TripleDetector {
    var swiftPath: CommandPathType
    var executor: CommandExecutor

    func detect() throws -> String {
        guard let data = try executor.run(command: try swiftPath.url(), arguments: ["-print-target-info"]) else { fatalError() }

        let info = try JSONDecoder().decode(SwiftTargetInfo.self, from: data)

        return info.target.unversionedTriple
    }
}
