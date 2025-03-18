//
//  cradle.swift
//  cradle
//
//  Created by trickart on 2025/03/04.
//

import ArgumentParser
import CradleKit
import Foundation

@main
struct CradleCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "cradle",
        subcommands: [
            InstallCommand.self,
            UpdateCommand.self,
            ShowCradlesLicensesCommand.self,
        ]
    )
}
