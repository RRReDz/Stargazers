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
        
        assert(sut, completesWith: .failure(error), on: {
            store.completeDeletionWithError(error)
        })
    }
    
    func test_clearStargazers_deliversSuccessOnStoreRepositoryDeletionCompletionSuccess() {
        let (sut, store) = makeSUT()
        
        assert(sut, completesWith: .success(()), on: {
            store.completeDeletionSuccessfully()
        })
    }
    
    func test_clearStargazers_doesNotDeliverResultsOnDeletionCompletionWhenInstanceHasBeenDeallocated() {
        var (sut, store) = makeOptionalSUT()
        
        let repository = useCaseRepository()
        var capturedResults = [Any]()
        sut?.clearStargazers(for: repository.model) { capturedResults.append($0) }
        
        sut = nil
        store.completeDeletionSuccessfully()
        
        XCTAssert(capturedResults.isEmpty, "Expected no results, got \(capturedResults) instead.")
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
        _ sut: LocalStargazersLoader,
        completesWith expectedResult: Result<Void, Error>,
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
    
    private func anyNSError() -> NSError {
        NSError(domain: "any nserror", code: -12345)
    }
    
    private func useCaseRepository() -> (model: Repository, local: LocalRepository) {
        let model = anyRepository()
        let local = LocalRepository(name: model.name, owner: model.owner)
        return (model, local)
    }

}
