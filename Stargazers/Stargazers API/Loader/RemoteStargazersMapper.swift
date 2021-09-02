//
//  RemoteStargazersMapper.swift
//  Stargazers
//
//  Created by Riccardo Rossi - Home on 09/08/21.
//

import Foundation

internal final class RemoteStargazersMapper {
    internal static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [RemoteStargazer] {
        guard
            response.isOK,
            let remoteStargazers = try? JSONDecoder().decode([RemoteStargazer].self, from: data)
        else {
            throw RemoteStargazersLoader.Error.invalidData
        }
        
        return remoteStargazers
    }
}
