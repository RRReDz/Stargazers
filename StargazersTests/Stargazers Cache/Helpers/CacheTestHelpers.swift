//
//  TestHelpers.swift
//  StargazersTests
//
//  Created by Riccardo Rossi - Home on 04/09/21.
//

import Foundation
import Stargazers

internal func useCaseRepository() -> (model: Repository, local: LocalRepository) {
    let model = anyRepository()
    let local = LocalRepository(name: model.name, owner: model.owner)
    return (model, local)
}

internal func uniqueUseCaseStargazers() -> (model: [Stargazer], local: [LocalStargazer]) {
    let stargazers = uniqueStargazers()
    
    return (
        stargazers,
        stargazers.map {
            LocalStargazer(
                id: $0.id,
                username: $0.username,
                avatarURL: $0.avatarURL,
                detailURL: $0.detailURL)
        }
    )
}
