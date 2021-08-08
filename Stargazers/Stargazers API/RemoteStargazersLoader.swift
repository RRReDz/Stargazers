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
        client.get(from: url) { response in
            completion(
                response
                .mapError { _ in Error.connectivity }
                .flatMap { (data, httpResponse)  in
                    if httpResponse.statusCode == 200,
                       let remoteStargazers = try? JSONDecoder().decode([RemoteStargazer].self, from: data) {
                        return .success(remoteStargazers.map { $0.toModel })
                    } else {
                        return .failure(.invalidData)
                    }
                }
            )
        }
    }
    
    private struct RemoteStargazer: Decodable {
        private let id: Int
        private let username: String
        private let avatar_url: URL
        private let user_datail_url: URL
        
        enum CodingKeys: String, CodingKey {
            case id
            case username = "login"
            case avatar_url
            case user_datail_url = "url"
        }
        
        var toModel: Stargazer {
            Stargazer(
                id: id,
                username: username,
                avatarURL: avatar_url,
                detailURL: user_datail_url)
        }
    }
}

