//
//  RemoteStargazersMapper.swift
//  Stargazers
//
//  Created by Riccardo Rossi - Home on 09/08/21.
//

import Foundation

internal final class RemoteStargazersMapper {
    
    internal static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [Stargazer] {
        guard
            response.isOK,
            let remoteStargazers = try? JSONDecoder().decode([Item].self, from: data)
        else {
            throw RemoteStargazersLoader.Error.invalidData
        }
        
        return remoteStargazers.toModels
    }
    
    internal struct Item: Decodable {
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
