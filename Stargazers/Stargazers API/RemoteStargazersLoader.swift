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
    
    public func load(completion: @escaping (Error) -> Void) {
        client.get(from: url) { response in
            switch response {
            case .failure:
                completion(.connectivity)
            case .success:
                completion(.invalidData)
            }
        }
    }
}
