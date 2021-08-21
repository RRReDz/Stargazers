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
        store.retrieve(from: repository.toLocal) {
            completion($0.map([Stargazer].init))
        }
    }
    
    func save(_ stargazers: [Stargazer], for repository: Repository) {
        store.deleteStargazers(for: repository.toLocal)
        store.insert(
            stargazers.map(LocalStargazer.init),
            for: repository.toLocal)
    }
    
    func clearStargazers(for repository: Repository, completion: @escaping (Result<Void, Error>) -> Void = { _ in }) {
        store.deleteStargazers(for: repository.toLocal) {
            completion($0)
        }
    }
}

class StargazersStore {
    typealias RetrieveCompletion = (Result<[LocalStargazer], Error>) -> Void
    
    enum Message: Equatable {
        case retrieveStargazers(for: LocalRepository)
        case deleteStargazers(for: LocalRepository)
        case insert([LocalStargazer], for: LocalRepository)
    }
    
    var messages = [Message]()
    private var retrieveCompletions = [RetrieveCompletion]()
    private var deleteCompletions = [(Result<Void, Error>) -> Void]()
    
    func retrieve(from repository: LocalRepository, completion: @escaping RetrieveCompletion) {
        messages.append(.retrieveStargazers(for: repository))
        retrieveCompletions.append(completion)
    }
    
    func insert(_ stargazers: [LocalStargazer], for repository: LocalRepository) {
        messages.append(.insert(stargazers, for: repository))
    }
    
    func deleteStargazers(for repository: LocalRepository, completion: @escaping (Result<Void, Error>) -> Void = { _ in }) {
        messages.append(.deleteStargazers(for: repository))
        deleteCompletions.append(completion)
    }
    
    func completeRetrievalWithError(at index: Int = 0) {
        let error = NSError(domain: "any retrieval error", code: 234234)
        retrieveCompletions[index](.failure(error))
    }
    
    func completeRetrievalSuccessfully(with stargazers: [LocalStargazer], at index: Int = 0) {
        retrieveCompletions[index](.success(stargazers))
    }
    
    func completeDeletionWithError(at index: Int = 0) {
        let error = NSError(domain: "any deletion error", code: 739584)
        deleteCompletions[index](.failure(error))
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deleteCompletions[index](.success(()))
    }
}

struct LocalRepository: Equatable {
    let name: String
    let owner: String
}

struct LocalStargazer: Equatable {
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

private extension LocalStargazer {
    init(model: Stargazer) {
        self.init(
            id: model.id,
            username: model.username,
            avatarURL: model.avatarURL,
            detailURL: model.detailURL)
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
    
    func test_clearStargazers_sendStoreDeleteRepositoryStargazersMessage() {
        let (sut, store) = makeSUT()
        let repository = makeUseCaseRepository()
        
        sut.clearStargazers(for: repository.model)
        
        XCTAssertEqual(store.messages, [.deleteStargazers(for: repository.local)])
    }
    
    func test_clearStargazers_deliversErrorOnStoreRepositoryDeletionCompletionError() {
        let (sut, store) = makeSUT()
        let repository = makeUseCaseRepository()
        
        let exp = expectation(description: "Wait for clearStargazers completion")
        sut.clearStargazers(for: repository.model) { result in
            switch result {
            case .failure:
                break
            default:
                XCTFail("Expected failure, got \(result) instead")
            }
            exp.fulfill()
        }
        
        store.completeDeletionWithError()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_clearStargazers_deliversSuccessOnStoreRepositoryDeletionCompletionSuccess() {
        let (sut, store) = makeSUT()
        let repository = makeUseCaseRepository()
        
        let exp = expectation(description: "Wait for clearStargazers completion")
        sut.clearStargazers(for: repository.model) { result in
            switch result {
            case .success:
                break
            default:
                XCTFail("Expected success, got \(result) instead")
            }
            exp.fulfill()
        }
        
        store.completeDeletionSuccessfully()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_save_sendStoreDeleteAndInsertRepositoryStargazersMessage() {
        let (sut, store) = makeSUT()
        let repository = makeUseCaseRepository()
        let stargazers = makeUniqueUseCaseStargazers()
        
        sut.save(stargazers.model, for: repository.model)
        
        XCTAssertEqual(store.messages, [
            .deleteStargazers(for: repository.local),
            .insert(stargazers.local, for: repository.local)
        ])
    }
    
    func test_load_sendStoreRetrieveRepositoryMessage() {
        let (sut, store) = makeSUT()
        let repository = makeUseCaseRepository()
        
        sut.load(from: repository.model) { _ in }
        
        XCTAssertEqual(store.messages, [.retrieveStargazers(for: repository.local)])
    }
    
    func test_load_deliversErrorOnStoreRetrievalCompletionError() {
        let (sut, store) = makeSUT()
        
        assert(that: sut, completesLoadWith: .failure(anyNSError()), on: {
            store.completeRetrievalWithError()
        })
    }
    
    func test_load_deliversStargazersOnStoreRetrievalCompletionWithLocalStargazers() {
        let (sut, store) = makeSUT()
        let stargazers = makeUniqueUseCaseStargazers()
        
        assert(that: sut, completesLoadWith: .success(stargazers.model), on: {
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
        completesLoadWith expectedResult: StargazersLoader.Result,
        on action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for load completion")
        sut.load(from: makeUseCaseRepository().model) { receivedResult in
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
    
    private func makeUseCaseRepository() -> (model: Repository, local: LocalRepository) {
        let model = anyRepository()
        let local = LocalRepository(name: model.name, owner: model.owner)
        return (model, local)
    }
    
    private func makeUniqueUseCaseStargazer() -> (model: Stargazer, local: LocalStargazer) {
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
    
    private func makeUniqueUseCaseStargazers() -> (model: [Stargazer], local: [LocalStargazer]) {
        let stargazer0 = makeUniqueUseCaseStargazer()
        let stargazer1 = makeUniqueUseCaseStargazer()
        return ([stargazer0.model, stargazer1.model], [stargazer0.local, stargazer1.local])
    }
    
}