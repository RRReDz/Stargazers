//
//  TestHelpers.swift
//  StargazersTests
//
//  Created by Riccardo Rossi - Home on 04/09/21.
//

import Stargazers

internal func useCaseRepository() -> (model: Repository, local: LocalRepository) {
    let model = anyRepository()
    let local = LocalRepository(name: model.name, owner: model.owner)
    return (model, local)
}
