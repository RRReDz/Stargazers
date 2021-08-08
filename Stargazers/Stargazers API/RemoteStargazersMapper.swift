//
//  RemoteStargazersMapper.swift
//  Stargazers
//
//  Created by Riccardo Rossi - Home on 09/08/21.
//

import Foundation

class RemoteStargazersMapper {
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
    
    static func map(_ data: Data, with response: HTTPURLResponse) throws -> [Stargazer] {
        guard response.statusCode == 200 else {
            throw RemoteStargazersLoader.Error.invalidData
        }
        let remoteStargazers = try JSONDecoder().decode([RemoteStargazer].self, from: data)
        return remoteStargazers.map { $0.toModel }
    }
}
