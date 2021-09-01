//
//  RemoteStargazersMapper.swift
//  Stargazers
//
//  Created by Riccardo Rossi - Home on 09/08/21.
//

import Foundation

internal struct RemoteStargazerItem: Decodable {
    internal let id: Int
    internal let login: String
    internal let avatar_url: URL
    internal let url: URL
}

internal final class RemoteStargazersMapper {
    
    internal static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [RemoteStargazerItem] {
        guard
            response.isOK,
            let remoteStargazers = try? JSONDecoder().decode([RemoteStargazerItem].self, from: data)
        else {
            throw RemoteStargazersLoader.Error.invalidData
        }
        
        return remoteStargazers
    }
}
