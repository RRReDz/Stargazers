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

internal func uniqueStargazer() -> (model: Stargazer, local: LocalStargazer) {
    let model = Stargazer(
        id: UUID().uuidString,
        username: "any username",
        avatarURL: anyURL(),
        detailURL: anyURL())
    
    let local = LocalStargazer(
        id: model.id,
        username: model.username,
        avatarURL: model.avatarURL,
        detailURL: model.detailURL)
    
    return (model, local)
}

internal func uniqueStargazers() -> (model: [Stargazer], local: [LocalStargazer]) {
    let stargazers = [uniqueStargazer(), uniqueStargazer()]
    return (
        stargazers.map { $0.model },
        stargazers.map { $0.local }
    )
}
