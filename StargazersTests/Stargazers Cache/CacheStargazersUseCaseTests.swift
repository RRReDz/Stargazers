//
//  CacheStargazersUseCaseTests.swift
//  StargazersTests
//
//  Created by Riccardo Rossi - Home on 04/09/21.
//

import XCTest
import Stargazers

class CacheStargazersUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStore() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.messages, [])
    }

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
        
        assert(sut, saveDoesNotDeliverResultsOn: {
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
    
    // MARK: - Utils
    
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
    
    private func assertIsEmpty(
        _ items: [Any],
        on action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        action()
        XCTAssert(items.isEmpty, "Expected no items, got \(items) instead.", file: file, line: line)
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
    
    private func anyNSError() -> NSError {
        NSError(domain: "any nserror", code: -12345)
    }

}
