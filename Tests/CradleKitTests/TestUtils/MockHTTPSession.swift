//
//  MockHTTPSession.swift
//  cradle
//
//  Created by Ryotaro Seki on 2025/03/23.
//

@testable import CradleKit
import Foundation

struct MockHTTPSession: HTTPSession {
    var outputs: [String: (Data, URLResponse)]

    func data(from url: URL) async throws -> (Data, URLResponse) {
        guard let output = outputs[url.absoluteString] else { fatalError() }
        return output
    }
}
