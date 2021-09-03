//
//  RemoteStargazersLoader.swift
//  Stargazers
//
//  Created by Riccardo Rossi - Home on 08/08/21.
//

import Foundation

public final class RemoteStargazersLoader {
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    private let url: (Repository) -> URL
    private let client: HTTPClient
    
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
            completion(Self.map($0))
        }
    }
    
    private static func map(_ result: HTTPClient.Result) -> Result {
        result
            .mapError { _ in Error.connectivity }
            .flatMap { data, response in
                Result { try RemoteStargazersMapper.map(data, response).toModels }
            }
    }
}
