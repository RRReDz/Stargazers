//
//  StargazersCleaner.swift
//  StargazersTests
//
//  Created by Riccardo Rossi - Home on 31/08/21.
//

import Stargazers

internal protocol StargazersCleaner {
    typealias Result = Swift.Result<Void, Error>
    func clearStargazers(for repository: Repository, completion: @escaping (Result) -> Void)
}
