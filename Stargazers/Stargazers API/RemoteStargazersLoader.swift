//
//  RemoteStargazersLoader.swift
//  Stargazers
//
//  Created by Riccardo Rossi - Home on 08/08/21.
//

import Foundation

public final class RemoteStargazersLoader {
    private let client: HTTPClient
    private let url: URL
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (Result<[Stargazer], Error>) -> Void) {
        client.get(from: url) { [weak self] in
            guard self != nil else { return }
            completion(
                $0.mapError { _ in Error.connectivity }
                .flatMap { (data, httpResponse) in
                    Result {
                        try RemoteStargazersMapper.map(data, with: httpResponse)
                    }
                    .mapError { _ in Error.invalidData }
                })
        }
    }
}

