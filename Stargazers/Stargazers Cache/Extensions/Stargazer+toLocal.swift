//
//  Stargazer+toLocal.swift
//  Stargazers
//
//  Created by Riccardo Rossi - Home on 27/08/21.
//

import Foundation

extension Stargazer {
    internal var toLocal: LocalStargazer {
        return LocalStargazer(
            id: id,
            username: username,
            avatarURL: avatarURL,
            detailURL: detailURL)
    }
}
