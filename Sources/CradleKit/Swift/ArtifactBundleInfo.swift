//
//  ArtifactBundleInfo.swift
//  cradle
//
//  Created by trickart on 2025/03/04.
//

struct ArtifactBundleInfo: Decodable {
    struct Artifact: Decodable {
        struct Variant: Decodable {
            var path: String
            var supportedTriples: [String]
        }

        var variants: [Variant]
    }

    var artifacts: [String: Artifact]
}
