//
//  RemoteStargazerItems+ModelMapping.swift
//  Stargazers
//
//  Created by Riccardo Rossi - Home on 09/08/21.
//

import Foundation

internal extension Array where Element == RemoteStargazerItem {
    var toModels: [Stargazer] {
        self.map {
            Stargazer(
                id: String($0.id),
                username: $0.login,
                avatarURL: $0.avatar_url,
                detailURL: $0.url)
        }
    }
}
