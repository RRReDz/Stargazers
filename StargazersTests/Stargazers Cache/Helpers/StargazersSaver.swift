//
//  StargazersSaver.swift
//  StargazersTests
//
//  Created by Riccardo Rossi - Home on 31/08/21.
//

import Stargazers

protocol StargazersSaver {
    typealias Result = Swift.Result<Void, Error>
    func save(_ stargazers: [Stargazer], for repository: Repository, completion: @escaping (Result) -> Void)
}
