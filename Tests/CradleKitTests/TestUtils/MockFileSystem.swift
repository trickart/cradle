//
//  MockFileSystem.swift
//  cradle
//
//  Created by trickart on 2025/03/23.
//

import CradleKit
import Foundation

class MockFileSystem: FileSystem {
    var currentDirectoryPath: String

    // path & isDirectory
    var fileExists: [String: Bool]

    var createdDirectories: [String] = []
    var wroteFiles: [String] = []

    init(currentDirectoryPath: String, fileExists: [String : Bool]) {
        self.currentDirectoryPath = currentDirectoryPath
        self.fileExists = fileExists
    }

    func setAttributes(_ attributes: [FileAttributeKey : Any], ofItemAtPath path: String) throws {}
    func createDirectory(atPath path: String, withIntermediateDirectories createIntermediates: Bool) throws {}

    func fileExists(atPath path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) -> Bool {
        if let isDir = fileExists[path] {
            isDirectory?.pointee = ObjCBool(isDir)
            return true
        } else {
            return false
        }
    }

    func createFile(atPath path: String, contents data: Data?) -> Bool { true }

    func createDirectoryIfNeeded(path: String) throws {
        createdDirectories.append(path)
    }

    func writeFile(path: String, data: Data) throws {
        wroteFiles.append(path)
    }
}
