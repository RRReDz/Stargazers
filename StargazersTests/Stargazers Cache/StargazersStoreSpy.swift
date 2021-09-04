//
//  StargazersStoreSpy.swift
//  StargazersTests
//
//  Created by Riccardo Rossi - Home on 04/09/21.
//

import Stargazers

class StargazersStoreSpy: StargazersStore {
    enum Message: Equatable {
        case retrieveStargazers(for: LocalRepository)
        case deleteStargazers(for: LocalRepository)
        case insert([LocalStargazer], for: LocalRepository)
    }
    
    private(set) var messages = [Message]()
    private var retrieveCompletions = [RetrieveCompletion]()
    private var deleteCompletions = [DeleteCompletion]()
    private var insertionCompletions = [InsertCompletion]()
    
    func retrieve(from repository: LocalRepository, completion: @escaping RetrieveCompletion) {
        messages.append(.retrieveStargazers(for: repository))
        retrieveCompletions.append(completion)
    }
    
    func insert(_ stargazers: [LocalStargazer], for repository: LocalRepository, completion: @escaping InsertCompletion) {
        messages.append(.insert(stargazers, for: repository))
        insertionCompletions.append(completion)
    }
    
    func deleteStargazers(for repository: LocalRepository, completion: @escaping DeleteCompletion) {
        messages.append(.deleteStargazers(for: repository))
        deleteCompletions.append(completion)
    }
    
    func completeRetrievalWithError(_ error: Error, at index: Int = 0) {
        retrieveCompletions[index](.failure(error))
    }
    
    func completeRetrievalSuccessfully(with stargazers: [LocalStargazer], at index: Int = 0) {
        retrieveCompletions[index](.success(stargazers))
    }
    
    func completeDeletionWithError(_ error: Error, at index: Int = 0) {
        deleteCompletions[index](.failure(error))
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deleteCompletions[index](.success(()))
    }
    
    func completeInsertionWithError(_ error: Error, at index: Int = 0) {
        insertionCompletions[index](.failure(error))
    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionCompletions[index](.success(()))
    }
}
