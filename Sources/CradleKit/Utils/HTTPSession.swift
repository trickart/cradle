//
//  HTTPSession.swift
//  cradle
//
//  Created by trickart on 2025/03/06.
//

import Foundation

public protocol HTTPSession {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

extension URLSession: HTTPSession {}

extension HTTPSession {
    func dataOnly(from url: URL) async throws -> Data {
        let (data, response) = try await data(from: url)

        let statsCode = (response as? HTTPURLResponse)?.statusCode
        guard statsCode == 200 else { throw CradleError.invalidStatusCode(statsCode, url) }

        return data
    }
}

