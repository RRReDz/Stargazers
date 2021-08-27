//
//  StargazersStore.swift
//  Stargazers
//
//  Created by Riccardo Rossi - Home on 27/08/21.
//

import Foundation

public protocol StargazersStore {
    typealias RetrieveCompletion = (Result<[LocalStargazer], Error>) -> Void
    typealias DeleteCompletion = (Result<Void, Error>) -> Void
    typealias InsertCompletion = (Result<Void, Error>) -> Void
    
    func retrieve(from repository: LocalRepository, completion: @escaping RetrieveCompletion)
    func insert(_ stargazers: [LocalStargazer], for repository: LocalRepository, completion: @escaping InsertCompletion)
    func deleteStargazers(for repository: LocalRepository, completion: @escaping DeleteCompletion)
}
