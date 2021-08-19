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
        private let login: String
        private let avatar_url: URL
        private let url: URL
        
        var toModel: Stargazer {
            Stargazer(
                id: String(id),
                username: login,
                avatarURL: avatar_url,
                detailURL: url)
        }
    }
}
