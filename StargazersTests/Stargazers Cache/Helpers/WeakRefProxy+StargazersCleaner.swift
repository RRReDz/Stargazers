//
//  WeakRefProxy+StargazersCleaner.swift
//  StargazersTests
//
//  Created by Riccardo Rossi - Home on 31/08/21.
//

import Stargazers

extension WeakRefProxy: StargazersCleaner where T: StargazersCleaner {
    internal func clearStargazers(for repository: Repository, completion: @escaping (T.Result) -> Void) {
        object?.clearStargazers(for: repository, completion: completion)
    }
}
