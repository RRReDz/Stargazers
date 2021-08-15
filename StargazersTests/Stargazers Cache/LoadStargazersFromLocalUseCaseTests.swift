//
//  LoadStargazersFromLocalUseCaseTests.swift
//  StargazersTests
//
//  Created by Riccardo Rossi - Home on 15/08/21.
//

import XCTest
import Stargazers

final class LocalStargazersLoader: StargazersLoader {
    private let store: StargazersStore
    
    init(store: StargazersStore) {
        self.store = store
    }
    
    func load(from repository: Repository, completion: @escaping (StargazersLoader.Result) -> Void) {
        store.retrieve(
            from: LocalRepository(
                name: repository.name,
                owner: repository.owner))
    }
}

class StargazersStore {
    enum Message: Equatable {
        case retrieve(LocalRepository)
    }
    
    var messages = [Message]()
    
    func retrieve(from repository: LocalRepository) {
        messages.append(.retrieve(repository))
    }
}

struct LocalRepository: Equatable {
    let name: String
    let owner: String
}

class LoadStargazersFromLocalUseCaseTests: XCTestCase {

    func test_init_doesNotMessageStore() {
        let store = StargazersStore()
        _ = LocalStargazersLoader(store: store)
        
        XCTAssertEqual(store.messages, [])
    }
    
    func test_load_sendStoreRetrieveRepositoryMessage() {
        let store = StargazersStore()
        let sut = LocalStargazersLoader(store: store)
        let (model, local) = makeRepository()
        
        sut.load(from: model) { _ in }
        
        XCTAssertEqual(store.messages, [.retrieve(local)])
    }
    
    //MARK: - Utils
    
    private func makeRepository() -> (model: Repository, local: LocalRepository) {
        let model = anyRepository()
        let local = LocalRepository(name: model.name, owner: model.owner)
        return (model, local)
    }

}
