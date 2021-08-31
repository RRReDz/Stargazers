//
//  LoadStargazersFromLocalUseCaseTests.swift
//  StargazersTests
//
//  Created by Riccardo Rossi - Home on 15/08/21.
//

import XCTest
import Stargazers

class LoadStargazersFromLocalUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStore() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.messages, [])
    }
    
    //MARK: - Clear Stargazers
    
    func test_clearStargazers_sendStoreDeleteRepositoryStargazersMessage() {
        let (sut, store) = makeSUT()
        let repository = useCaseRepository()
        
        sut.clearStargazers(for: repository.model) { _ in }
        
        XCTAssertEqual(store.messages, [.deleteStargazers(for: repository.local)])
    }
    
    func test_clearStargazers_deliversErrorOnStoreRepositoryDeletionCompletionError() {
        let (sut, store) = makeSUT()
        let error = anyNSError()
        
        assert(that: sut, completesClearWith: .failure(error), on: {
            store.completeDeletionWithError(error)
        })
    }
    
    func test_clearStargazers_deliversSuccessOnStoreRepositoryDeletionCompletionSuccess() {
        let (sut, store) = makeSUT()
        
        assert(that: sut, completesClearWith: .success(()), on: {
            store.completeDeletionSuccessfully()
        })
    }
    
    func test_clearStargazers_doesNotDeliverResultsOnDeletionCompletionWhenInstanceHasBeenDeallocated() {
        var (sut, store) = makeOptionalSUT()
        
        assert(sut.toWeak, clearDoesNotDeliverResultsOn: {
            sut = nil
            store.completeDeletionSuccessfully()
        })
    }
    
    //MARK: - Save Stargazers
    
    func test_save_sendStoreDeleteRepositoryStargazersMessage() {
        let (sut, store) = makeSUT()
        let repository = useCaseRepository()
        
        sut.save(uniqueStargazers().model, for: repository.model) { _ in }
        
        XCTAssertEqual(store.messages, [.deleteStargazers(for: repository.local)])
    }
    
    func test_save_sendOnlyDeleteMessageAfterDeletionError() {
        let (sut, store) = makeSUT()
        let repository = useCaseRepository()
        
        sut.save(uniqueStargazers().model, for: repository.model) { _ in }
        store.completeDeletionWithError(anyNSError())
        
        XCTAssertEqual(store.messages, [.deleteStargazers(for: repository.local)])
    }
    
    func test_save_sendStoreDeleteAndInsertMessagesOnDeletionSuccess() {
        let (sut, store) = makeSUT()
        let repository = useCaseRepository()
        let stargazers = uniqueStargazers()
        
        sut.save(stargazers.model, for: repository.model) { _ in }
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.messages, [
            .deleteStargazers(for: repository.local),
            .insert(stargazers.local, for: repository.local)
        ])
    }
    
    func test_save_sendStoreDeleteAndInsertMessagesOnDeletionSuccessAndInsertionError() {
        let (sut, store) = makeSUT()
        let repository = useCaseRepository()
        let stargazers = uniqueStargazers()
        
        sut.save(stargazers.model, for: repository.model) { _ in }
        store.completeDeletionSuccessfully()
        store.completeInsertionWithError(anyNSError())
        
        XCTAssertEqual(store.messages, [
            .deleteStargazers(for: repository.local),
            .insert(stargazers.local, for: repository.local)
        ])
    }
    
    func test_save_sendStoreDeleteAndInsertMessagesOnDeletionSuccessAndInsertionSuccess() {
        let (sut, store) = makeSUT()
        let repository = useCaseRepository()
        let stargazers = uniqueStargazers()
        
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
        let error = anyNSError()
        
        assert(that: sut, completesSaveWith: .failure(error), on: {
            store.completeDeletionWithError(error)
        })
    }
    
    func test_save_doesNotDeliverResultJustOnDeletionSuccess() {
        let (sut, store) = makeSUT()
        
        assert(sut.toWeak, saveDoesNotDeliverResultsOn: {
            store.completeDeletionSuccessfully()
        })
    }
    
    func test_save_deliversErrorOnDeletionSuccessAndInsertionError() {
        let (sut, store) = makeSUT()
        let error = anyNSError()
        
        assert(that: sut, completesSaveWith: .failure(error), on: {
            store.completeDeletionSuccessfully()
            store.completeInsertionWithError(error)
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
        let stargazers = uniqueStargazers().model
        let repository = useCaseRepository()
        var (sut, store) = makeOptionalSUT()
        
        sut?.save(stargazers, for: repository.model) { _ in }
        
        sut = nil
        
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.messages, [.deleteStargazers(for: repository.local)])
    }
    
    func test_save_doesNotDeliverResultWhenInstanceHasBeenDeallocatedAndCompleteDeletionWithError() {
        var (sut, store) = makeOptionalSUT()
        
        assert(sut.toWeak, saveDoesNotDeliverResultsOn: {
            sut = nil
            store.completeDeletionWithError(anyNSError())
        })
    }
    
    func test_save_doesNotDeliverResultOnSuccessfulDeletionThenInstanceIsDeallocatedAndInsertionCompleted() {
        var (sut, store) = makeOptionalSUT()
        
        assert(sut.toWeak, saveDoesNotDeliverResultsOn: {
            store.completeDeletionSuccessfully()
            sut = nil
            store.completeInsertionSuccessfully()
        })
    }
    
    //MARK: - Load Stargazers
    
    func test_load_sendStoreRetrieveRepositoryMessage() {
        let (sut, store) = makeSUT()
        let repository = useCaseRepository()
        
        sut.load(from: repository.model) { _ in }
        
        XCTAssertEqual(store.messages, [.retrieveStargazers(for: repository.local)])
    }
    
    func test_load_deliversErrorOnStoreRetrievalCompletionError() {
        let (sut, store) = makeSUT()
        let error = anyNSError()
        
        assert(that: sut, completesLoadWith: .failure(error), on: {
            store.completeRetrievalWithError(error)
        })
    }
    
    func test_load_deliversStargazersOnStoreRetrievalCompletionWithLocalStargazers() {
        let (sut, store) = makeSUT()
        let stargazers = uniqueStargazers()
        
        assert(that: sut, completesLoadWith: .success(stargazers.model), on: {
            store.completeRetrievalSuccessfully(with: stargazers.local)
        })
    }
    
    func test_load_doesNotDeliverResultOnStoreCompletionWhenSUTHasBeenDeallocated() {
        var (sut, store) = makeOptionalSUT()
        
        assert(sut.toWeak, loadDoesNotDeliverResultsOn: {
            sut = nil
            store.completeRetrievalSuccessfully(with: uniqueStargazers().local)
            store.completeRetrievalWithError(anyNSError())
        })
    }
    
    //MARK: - Utils
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (LocalStargazersLoader, StargazersStoreSpy) {
        let store = StargazersStoreSpy()
        let sut = LocalStargazersLoader(store: store)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        return (sut, store)
    }
    
    private func makeOptionalSUT(file: StaticString = #filePath, line: UInt = #line) -> (LocalStargazersLoader?, StargazersStoreSpy) {
        return makeSUT()
    }
    
    private class StargazersStoreSpy: StargazersStore {
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
    
    private func assert(
        that sut: LocalStargazersLoader,
        completesLoadWith expectedResult: StargazersLoader.Result,
        on action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for load completion")
        sut.load(from: useCaseRepository().model) { receivedResult in
            switch (expectedResult, receivedResult) {
            case let (.success(receivedStargazers), .success(expectedStargazers)):
                XCTAssertEqual(receivedStargazers, expectedStargazers, file: file, line: line)
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
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
        sut.clearStargazers(for: useCaseRepository().model) { receivedResult in
            switch (expectedResult, receivedResult) {
            case (.success, .success):
                break
            case let (.failure(expectedError as NSError), .failure(receivedError as NSError)):
                XCTAssertEqual(expectedError, receivedError, file: file, line: line)
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
        sut.save(uniqueStargazers().model, for: anyRepository()) { receivedResult in
            switch (expectedResult, receivedResult) {
            case (.success, .success):
                break
            case let (.failure(expectedError as NSError), .failure(receivedError as NSError)):
                XCTAssertEqual(expectedError, receivedError, file: file, line: line)
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func assert(
        _ sut: StargazersSaver,
        saveDoesNotDeliverResultsOn action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let stargazers = uniqueStargazers().model
        let repository = useCaseRepository()
        var capturedResults = [Any]()
        sut.save(stargazers, for: repository.model) { capturedResults.append($0) }
        assertIsEmpty(capturedResults, on: action, file: file, line: line)
    }
    
    private func assert(
        _ sut: StargazersLoader,
        loadDoesNotDeliverResultsOn action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let repository = useCaseRepository()
        var capturedResults = [Any]()
        sut.load(from: repository.model) { capturedResults.append($0) }
        assertIsEmpty(capturedResults, on: action, file: file, line: line)
    }
    
    private func assert(
        _ sut: StargazersCleaner,
        clearDoesNotDeliverResultsOn action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let repository = useCaseRepository()
        var capturedResults = [Any]()
        sut.clearStargazers(for: repository.model) { capturedResults.append($0) }
        assertIsEmpty(capturedResults, on: action, file: file, line: line)
    }
    
    private func assertIsEmpty(
        _ items: [Any],
        on action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line)
    {
        action()
        XCTAssert(items.isEmpty, "Expected no items, got \(items) instead.", file: file, line: line)
    }
    
    private func anyNSError() -> NSError {
        NSError(domain: "any nserror", code: -12345)
    }
    
    private func useCaseRepository() -> (model: Repository, local: LocalRepository) {
        let model = anyRepository()
        let local = LocalRepository(name: model.name, owner: model.owner)
        return (model, local)
    }
    
    private func uniqueStargazer() -> (model: Stargazer, local: LocalStargazer) {
        let model = Stargazer(
            id: UUID().uuidString,
            username: "any",
            avatarURL: URL(string: "http://any-avatar-url.com")!,
            detailURL: URL(string: "http://any-detail-url.com")!)
        
        let local = LocalStargazer(
            id: model.id,
            username: model.username,
            avatarURL: model.avatarURL,
            detailURL: model.detailURL)
        return (model, local)
    }
    
    private func uniqueStargazers() -> (model: [Stargazer], local: [LocalStargazer]) {
        let stargazers = [uniqueStargazer(), uniqueStargazer()]
        return (
            stargazers.map { $0.model },
            stargazers.map { $0.local }
        )
    }
    
}

private class WeakRefProxy<T: AnyObject> {
    private(set) weak var object: T?
    
    init(_ object: T?) {
        self.object = object
    }
}

private protocol StargazersCleaner {
    typealias Result = Swift.Result<Void, Error>
    func clearStargazers(for repository: Repository, completion: @escaping (Result) -> Void)
}

private protocol StargazersSaver {
    typealias Result = Swift.Result<Void, Error>
    func save(_ stargazers: [Stargazer], for repository: Repository, completion: @escaping (Result) -> Void)
}

extension WeakRefProxy: StargazersLoader where T: StargazersLoader {
    func load(from repository: Repository, completion: @escaping (T.Result) -> Void) {
        object?.load(from: repository, completion: completion)
    }
}

extension WeakRefProxy: StargazersCleaner where T: StargazersCleaner {
    func clearStargazers(for repository: Repository, completion: @escaping (T.Result) -> Void) {
        object?.clearStargazers(for: repository, completion: completion)
    }
}

extension WeakRefProxy: StargazersSaver where T: StargazersSaver {
    func save(_ stargazers: [Stargazer], for repository: Repository, completion: @escaping (T.Result) -> Void) {
        object?.save(stargazers, for: repository, completion: completion)
    }
}

private extension LocalStargazersLoader {
    var toWeak: WeakRefProxy<LocalStargazersLoader> { .init(self) }
}

extension LocalStargazersLoader: StargazersCleaner {}

extension LocalStargazersLoader: StargazersSaver {}

private extension Optional where Wrapped == LocalStargazersLoader {
    var toWeak: WeakRefProxy<Wrapped> { .init(self) }
}
