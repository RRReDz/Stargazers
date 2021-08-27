//
//  LocalStargazer+toModel.swift
//  Stargazers
//
//  Created by Riccardo Rossi - Home on 27/08/21.
//

import Foundation

extension LocalStargazer {
    var toModel: Stargazer {
        Stargazer(
            id: id,
            username: username,
            avatarURL: avatarURL,
            detailURL: detailURL)
    }
}
