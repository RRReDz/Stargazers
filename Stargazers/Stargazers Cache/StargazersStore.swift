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
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func retrieve(from repository: LocalRepository, completion: @escaping RetrieveCompletion)
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func insert(_ stargazers: [LocalStargazer], for repository: LocalRepository, completion: @escaping InsertCompletion)
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func deleteStargazers(for repository: LocalRepository, completion: @escaping DeleteCompletion)
}
