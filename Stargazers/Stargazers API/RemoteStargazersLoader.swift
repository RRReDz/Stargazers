//
//  RemoteStargazersLoader.swift
//  Stargazers
//
//  Created by Riccardo Rossi - Home on 08/08/21.
//

import Foundation

public final class RemoteStargazersLoader {
    private let url: (Repository) -> URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public init(url: @escaping (Repository) -> URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
}

extension RemoteStargazersLoader: StargazersLoader {
    public typealias Result = StargazersLoader.Result
    
    public func load(from repository: Repository, completion: @escaping (Result) -> Void) {
        client.get(from: url(repository)) { [weak self] in
            guard self != nil else { return }
            completion(
                $0.mapError { _ in Error.connectivity }
                .flatMap { data, response in Result { try RemoteStargazersMapper.map(data, response) } }
            )
        }
    }
}
