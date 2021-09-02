//
//  WeakRefProxy+TypeConformances.swift
//  StargazersTests
//
//  Created by Riccardo Rossi - Home on 31/08/21.
//

import Stargazers

extension WeakRefProxy: StargazersLoader where T: StargazersLoader {
    internal func load(from repository: Repository, completion: @escaping (T.Result) -> Void) {
        object?.load(from: repository, completion: completion)
    }
}

extension WeakRefProxy: StargazersCleaner where T: StargazersCleaner {
    internal func clearStargazers(for repository: Repository, completion: @escaping (T.Result) -> Void) {
        object?.clearStargazers(for: repository, completion: completion)
    }
}

extension WeakRefProxy: StargazersSaver where T: StargazersSaver {
    internal func save(_ stargazers: [Stargazer], for repository: Repository, completion: @escaping (T.Result) -> Void) {
        object?.save(stargazers, for: repository, completion: completion)
    }
}
