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
        store.retrieve(from: LocalRepository(name: repository.name, owner: repository.owner)) { error in
            completion(.failure(error))
        }
    }
}

class StargazersStore {
    typealias RetrieveCompletion = (Error) -> Void
    enum Message: Equatable {
        case retrieve(LocalRepository)
    }
    
    var messages = [Message]()
    private var completions = [RetrieveCompletion]()
    
    func retrieve(from repository: LocalRepository, completion: @escaping RetrieveCompletion) {
        messages.append(.retrieve(repository))
        completions.append(completion)
    }
    
    func completeRetrievalWithError(at index: Int = 0) {
        let error = NSError(domain: "any", code: 1)
        completions[index](error)
    }
}

struct LocalRepository: Equatable {
    let name: String
    let owner: String
}

class LoadStargazersFromLocalUseCaseTests: XCTestCase {

    func test_init_doesNotMessageStore() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.messages, [])
    }
    
    func test_load_sendStoreRetrieveRepositoryMessage() {
        let (sut, store) = makeSUT()
        let (model, local) = makeRepository()
        
        sut.load(from: model) { _ in }
        
        XCTAssertEqual(store.messages, [.retrieve(local)])
    }
    
    func test_load_deliversErrorOnStoreError() {
        let (sut, store) = makeSUT()
        
        let exp = expectation(description: "Wait for load completion")
        sut.load(from: anyRepository()) { result in
            switch result {
            case .failure:
                break
            default:
                XCTFail("Expected failre, got \(result) instead")
            }
            exp.fulfill()
        }
        
        store.completeRetrievalWithError()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    //MARK: - Utils
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (LocalStargazersLoader, StargazersStore) {
        let store = StargazersStore()
        let sut = LocalStargazersLoader(store: store)
        trackForMemoryLeak(sut, file: file, line: line)
        trackForMemoryLeak(store, file: file, line: line)
        return (sut, store)
    }
    
    private func makeRepository() -> (model: Repository, local: LocalRepository) {
        let model = anyRepository()
        let local = LocalRepository(name: model.name, owner: model.owner)
        return (model, local)
    }

}
