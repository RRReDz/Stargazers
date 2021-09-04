//
//  WeakRefProxy+StargazersSaver.swift
//  StargazersTests
//
//  Created by Riccardo Rossi - Home on 04/09/21.
//

import Stargazers

extension WeakRefProxy: StargazersSaver where T: StargazersSaver {
    internal func save(_ stargazers: [Stargazer], for repository: Repository, completion: @escaping (T.Result) -> Void) {
        object?.save(stargazers, for: repository, completion: completion)
    }
}
