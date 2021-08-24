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
    
    func save(_ stargazers: [Stargazer], for repository: Repository, completion: @escaping (Result<Void, Error>) -> Void) {
        store.deleteStargazers(for: repository.toLocal) { [weak self] result in
            switch result {
            case .success:
                self?.store.insert(stargazers.map(LocalStargazer.init), for: repository.toLocal, completion: completion)
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    func clearStargazers(for repository: Repository, completion: @escaping (Result<Void, Error>) -> Void) {
        store.deleteStargazers(for: repository.toLocal, completion: completion)
    }
}

class StargazersStore {
    typealias RetrieveCompletion = (Result<[LocalStargazer], Error>) -> Void
    typealias DeleteCompletion = (Result<Void, Error>) -> Void
    typealias InsertCompletion = (Result<Void, Error>) -> Void
    
    enum Message: Equatable {
        case retrieveStargazers(for: LocalRepository)
        case deleteStargazers(for: LocalRepository)
        case insert([LocalStargazer], for: LocalRepository)
    }
    
    var messages = [Message]()
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
    
    func completeInsertionWithError(at index: Int = 0) {
        let error = NSError(domain: "any insertion error", code: 834957)
        insertionCompletions[index](.failure(error))
    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionCompletions[index](.success(()))
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
    
    //MARK: - Clear Stargazers
    
    func test_clearStargazers_sendStoreDeleteRepositoryStargazersMessage() {
        let (sut, store) = makeSUT()
        let repository = makeUseCaseRepository()
        
        sut.clearStargazers(for: repository.model) { _ in }
        
        XCTAssertEqual(store.messages, [.deleteStargazers(for: repository.local)])
    }
    
    func test_clearStargazers_deliversErrorOnStoreRepositoryDeletionCompletionError() {
        let (sut, store) = makeSUT()
        
        assert(that: sut, completesClearWith: .failure(anyNSError()), on: {
            store.completeDeletionWithError()
        })
    }
    
    func test_clearStargazers_deliversSuccessOnStoreRepositoryDeletionCompletionSuccess() {
        let (sut, store) = makeSUT()
        
        assert(that: sut, completesClearWith: .success(()), on: {
            store.completeDeletionSuccessfully()
        })
    }
    
    //MARK: - Save Stargazers
    
    func test_save_sendStoreDeleteRepositoryStargazersMessage() {
        let (sut, store) = makeSUT()
        let repository = makeUseCaseRepository()
        
        sut.save(makeUniqueUseCaseStargazers().model, for: repository.model) { _ in }
        
        XCTAssertEqual(store.messages, [.deleteStargazers(for: repository.local)])
    }
    
    func test_save_sendOnlyDeleteMessageAfterDeletionError() {
        let (sut, store) = makeSUT()
        let repository = makeUseCaseRepository()
        
        sut.save(makeUniqueUseCaseStargazers().model, for: repository.model) { _ in }
        store.completeDeletionWithError()
        
        XCTAssertEqual(store.messages, [.deleteStargazers(for: repository.local)])
    }
    
    func test_save_sendStoreDeleteAndInsertMessagesOnDeletionSuccess() {
        let (sut, store) = makeSUT()
        let repository = makeUseCaseRepository()
        let stargazers = makeUniqueUseCaseStargazers()
        
        sut.save(stargazers.model, for: repository.model) { _ in }
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.messages, [
            .deleteStargazers(for: repository.local),
            .insert(stargazers.local, for: repository.local)
        ])
    }
    
    func test_save_sendStoreDeleteAndInsertMessagesOnDeletionSuccessAndInsertionError() {
        let (sut, store) = makeSUT()
        let repository = makeUseCaseRepository()
        let stargazers = makeUniqueUseCaseStargazers()
        
        sut.save(stargazers.model, for: repository.model) { _ in }
        store.completeDeletionSuccessfully()
        store.completeInsertionWithError()
        
        XCTAssertEqual(store.messages, [
            .deleteStargazers(for: repository.local),
            .insert(stargazers.local, for: repository.local)
        ])
    }
    
    func test_save_sendStoreDeleteAndInsertMessagesOnDeletionSuccessAndInsertionSuccess() {
        let (sut, store) = makeSUT()
        let repository = makeUseCaseRepository()
        let stargazers = makeUniqueUseCaseStargazers()
        
        sut.save(stargazers.model, for: repository.model) { _ in }
        store.completeDeletionSuccessfully()
        store.completeInsertionSuccessfully()
        
        XCTAssertEqual(store.messages, [
            .deleteStargazers(for: repository.local),
            .insert(stargazers.local, for: repository.local)
        ])
    }
    
    func test_save_deliversErrorOnDeletionError() {
        let (sut, store) = makeSUT()
        
        assert(that: sut, completesSaveWith: .failure(anyNSError()), on: {
            store.completeDeletionWithError()
        })
    }
    
    func test_save_deliversErrorOnDeletionSuccessAndInsertionError() {
        let (sut, store) = makeSUT()
        
        assert(that: sut, completesSaveWith: .failure(anyNSError()), on: {
            store.completeDeletionSuccessfully()
            store.completeInsertionWithError()
        })
    }
    
    func test_save_deliversSuccessOnDeletionSuccessAndInsertionSuccess() {
        let (sut, store) = makeSUT()
        
        assert(that: sut, completesSaveWith: .success(()), on: {
            store.completeDeletionSuccessfully()
            store.completeInsertionSuccessfully()
        })
    }
    
    func test_save_doesNotSendStoreInsertMessageWhenInstanceHasBeenDeallocatedAndCompleteDeletionSuccessfully() {
        let stargazers = makeUniqueUseCaseStargazers().model
        let repository = makeUseCaseRepository()
        let store = StargazersStore()
        var sut: LocalStargazersLoader? = .init(store: store)
        
        sut?.save(stargazers, for: repository.model) { _ in }
        
        sut = nil
        
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.messages, [.deleteStargazers(for: repository.local)])
    }
    
    //MARK: - Load Stargazers
    
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
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)
    }
    
    private func assert(
        that sut: LocalStargazersLoader,
        completesClearWith expectedResult: Result<Void, Error>,
        on action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for clearStargazers completion")
        sut.clearStargazers(for: makeUseCaseRepository().model) { receivedResult in
            switch (expectedResult, receivedResult) {
            case (.success, .success):
                break
            case (.failure, .failure):
                break
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func assert(
        that sut: LocalStargazersLoader,
        completesSaveWith expectedResult: Result<Void, Error>,
        on action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for save completion")
        sut.save([makeUniqueStargazer()], for: anyRepository()) { receivedResult in
            switch (expectedResult, receivedResult) {
            case (.success, .success):
                break
            case (.failure, .failure):
                break
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func anyNSError() -> NSError {
        NSError(domain: "any nserror", code: -12345)
    }
    
    private func makeUseCaseRepository() -> (model: Repository, local: LocalRepository) {
        let model = anyRepository()
        let local = LocalRepository(name: model.name, owner: model.owner)
        return (model, local)
    }
    
    private func makeUniqueUseCaseStargazer() -> (model: Stargazer, local: LocalStargazer) {
        let model = makeUniqueStargazer()
        let local = LocalStargazer(
            id: model.id,
            username: model.username,
            avatarURL: model.avatarURL,
            detailURL: model.detailURL)
        return (model, local)
    }
    
    private func makeUniqueStargazer() -> Stargazer {
        return Stargazer(
            id: UUID().uuidString,
            username: "any",
            avatarURL: URL(string: "http://any-url.com")!,
            detailURL: URL(string: "http://another-url.com")!)
    }
    
    private func makeUniqueUseCaseStargazers() -> (model: [Stargazer], local: [LocalStargazer]) {
        let stargazer0 = makeUniqueUseCaseStargazer()
        let stargazer1 = makeUniqueUseCaseStargazer()
        return ([stargazer0.model, stargazer1.model], [stargazer0.local, stargazer1.local])
    }
    
}
