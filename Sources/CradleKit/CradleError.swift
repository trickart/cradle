//
//  CradleError.swift
//  cradle
//
//  Created by trickart on 2025/03/04.
//

import Foundation

enum CradleError: Error {
    case invalidStatusCode(Int? ,URL)
    case notHaveArtifactBundle(URL)
    case notHaveInfoJson(URL)
    case emptyArtifactBundle(URL)
    case createDirectory(String)
    case createFile(String)
}
