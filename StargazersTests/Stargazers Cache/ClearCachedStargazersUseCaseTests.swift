//
//  ClearCachedStargazersUseCaseTests.swift
//  StargazersTests
//
//  Created by Riccardo Rossi - Home on 04/09/21.
//

import XCTest
import Stargazers

class ClearCachedStargazersUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStore() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.messages, [])
    }

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
        line: UInt = #line
    ) {
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

}
