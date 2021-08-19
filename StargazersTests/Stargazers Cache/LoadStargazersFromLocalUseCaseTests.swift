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
        store.retrieve(from: repository.toLocal) { result in
            completion(result.map([Stargazer].init))
        }
    }
}

class StargazersStore {
    typealias RetrieveCompletion = (Result<[LocalStargazer], Error>) -> Void
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
        let error = NSError(domain: "any retrieval error", code: 234234)
        completions[index](.failure(error))
    }
    
    func completeRetrievalSuccessfully(with stargazers: [LocalStargazer], at index: Int = 0) {
        completions[index](.success(stargazers))
    }
}

struct LocalRepository: Equatable {
    let name: String
    let owner: String
}

struct LocalStargazer {
    let id: String
    let username: String
    let avatarURL: URL
    let detailURL: URL
}

private extension Array where Element == Stargazer {
    init(local: [LocalStargazer]) {
        self.init(local.map(Stargazer.init))
    }
}

private extension Stargazer {
    init(local: LocalStargazer) {
        self.init(
            id: local.id,
            username: local.username,
            avatarURL: local.avatarURL,
            detailURL: local.detailURL)
    }
}

private extension Repository {
    var toLocal: LocalRepository {
        LocalRepository(
            name: name,
            owner: owner)
    }
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
    
    func test_load_deliversErrorOnStoreRetrievalCompletionError() {
        let (sut, store) = makeSUT()
        
        assert(that: sut, completesWith: .failure(anyNSError()), on: {
            store.completeRetrievalWithError()
        })
    }
    
    func test_load_deliversStargazersOnStoreRetrievalCompletionWithLocalStargazers() {
        let (sut, store) = makeSUT()
        let stargazers = makeUniqueStargazers()
        
        assert(that: sut, completesWith: .success(stargazers.model), on: {
            store.completeRetrievalSuccessfully(with: stargazers.local)
        })
    }
    
    //MARK: - Utils
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (LocalStargazersLoader, StargazersStore) {
        let store = StargazersStore()
        let sut = LocalStargazersLoader(store: store)
        trackForMemoryLeak(sut, file: file, line: line)
        trackForMemoryLeak(store, file: file, line: line)
        return (sut, store)
    }
    
    private func assert(
        that sut: LocalStargazersLoader,
        completesWith expectedResult: StargazersLoader.Result,
        on action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for load completion")
        sut.load(from: makeRepository().model) { receivedResult in
            switch (expectedResult, receivedResult) {
            case let (.success(receivedStargazers), .success(expectedStargazers)):
                XCTAssertEqual(receivedStargazers, expectedStargazers, file: file, line: line)
            case (.failure, .failure):
                break
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead")
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)
    }
    
    private func anyNSError() -> NSError {
        NSError(domain: "any", code: -1)
    }
    
    private func makeRepository() -> (model: Repository, local: LocalRepository) {
        let model = anyRepository()
        let local = LocalRepository(name: model.name, owner: model.owner)
        return (model, local)
    }
    
    private func makeUniqueStargazer() -> (model: Stargazer, local: LocalStargazer) {
        let model = Stargazer(
            id: UUID().uuidString,
            username: "any",
            avatarURL: URL(string: "http://any-url.com")!,
            detailURL: URL(string: "http://another-url.com")!)
        let local = LocalStargazer(
            id: model.id,
            username: model.username,
            avatarURL: model.avatarURL,
            detailURL: model.detailURL)
        return (model, local)
    }
    
    private func makeUniqueStargazers() -> (model: [Stargazer], local: [LocalStargazer]) {
        let stargazer0 = makeUniqueStargazer()
        let stargazer1 = makeUniqueStargazer()
        return ([stargazer0.model, stargazer1.model], [stargazer0.local, stargazer1.local])
    }
    
}
