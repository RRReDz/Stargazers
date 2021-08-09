//
//  URLSessionHTTPClient.swift
//  Stargazers
//
//  Created by Riccardo Rossi - Home on 09/08/21.
//

import Foundation

public final class URLSessionHTTPClient {
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void = { _ in }) {
        session.dataTask(with: url) { _, _, error in
            error.map { completion(.failure($0)) }
        }.resume()
    }
}
