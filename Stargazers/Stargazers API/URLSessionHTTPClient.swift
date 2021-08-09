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
    
    private struct UnexpectedValueRepresentation: Error {}
    
    public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void = { _ in }) {
        session.dataTask(with: url) { data, response, error in
            if let data = data, !data.isEmpty, let response = response as? HTTPURLResponse {
                completion(.success((data, response)))
            } else if let error = error {
                completion(.failure(error))
            } else {
                completion(.failure(UnexpectedValueRepresentation()))
            }
        }.resume()
    }
}
