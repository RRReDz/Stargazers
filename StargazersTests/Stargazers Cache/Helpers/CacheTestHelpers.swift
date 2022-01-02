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
    let uniqueUseCaseStargazer: () -> (model: Stargazer, local: LocalStargazer) = {
        let model = uniqueStargazer()
        let local = LocalStargazer(
            id: model.id,
            username: model.username,
            avatarURL: model.avatarURL,
            detailURL: model.detailURL)
        
        return (model, local)
    }
    
    let stargazers = [
        uniqueUseCaseStargazer(),
        uniqueUseCaseStargazer()
    ]
    
    return (
        stargazers.map { $0.model },
        stargazers.map { $0.local }
    )
}
