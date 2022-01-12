//
//  LoadStargazersFromCacheUseCaseTests.swift
//  StargazersTests
//
//  Created by Riccardo Rossi - Home on 15/08/21.
//

import XCTest
import Stargazers

class LoadStargazersFromCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStore() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.messages, [])
    }
    
    // MARK: - Load Stargazers
    
    func test_load_sendStoreRetrieveRepositoryMessage() {
        let (sut, store) = makeSUT()
        let repository = useCaseRepository()
        
        sut.load(from: repository.model) { _ in }
        
        XCTAssertEqual(store.messages, [.retrieveStargazers(for: repository.local)])
    }
    
    func test_load_deliversErrorOnStoreRetrievalCompletionError() {
        let (sut, store) = makeSUT()
        let error = anyNSError()
        
        assert(sut, completesWith: .failure(error), on: {
            store.completeRetrievalWithError(error)
        })
    }
    
    func test_load_deliversStargazersOnStoreRetrievalCompletionWithLocalStargazers() {
        let (sut, store) = makeSUT()
        let stargazers = uniqueUseCaseStargazers()
        
        assert(sut, completesWith: .success(stargazers.model), on: {
            store.completeRetrievalSuccessfully(with: stargazers.local)
        })
    }
    
    func test_load_doesNotDeliverResultsOnStoreCompletionWhenSUTHasBeenDeallocated() {
        var (sut, store) = makeOptionalSUT()
        
        var capturedResults = [Any]()
        sut?.load(from: useCaseRepository().model) { capturedResults.append($0) }
        
        sut = nil
        store.completeRetrievalSuccessfully(with: uniqueUseCaseStargazers().local)
        store.completeRetrievalWithError(anyNSError())
        
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
        completesWith expectedResult: StargazersLoader.Result,
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
}
