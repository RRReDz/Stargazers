//
//  RemoteStargazerItems+ModelMapping.swift
//  Stargazers
//
//  Created by Riccardo Rossi - Home on 09/08/21.
//

import Foundation

extension Array where Element == RemoteStargazer {
    internal var toModels: [Stargazer] {
        self.map {
            Stargazer(
                id: String($0.id),
                username: $0.login,
                avatarURL: $0.avatar_url,
                detailURL: $0.url
            )
        }
    }
}
