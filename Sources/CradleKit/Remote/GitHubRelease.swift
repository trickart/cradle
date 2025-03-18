//
//  GitHubRelease.swift
//  cradle
//
//  Created by trickart on 2025/03/04.
//

import Foundation

struct GitHubRelease: Decodable {
    struct Asset: Decodable {
        var name: String
        var browserDownloadUrl: URL
    }

    var tagName: String
    var assets: [Asset]
}

extension GitHubRelease {
    var artifactBundleURL: URL? {
        assets.first(where: { asset in
            asset.name.hasSuffix("artifactbundle.zip")
        })?.browserDownloadUrl
    }
}
