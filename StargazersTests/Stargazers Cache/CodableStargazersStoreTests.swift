//
//  CodableStargazersStoreTests.swift
//  StargazersTests
//
//  Created by Riccardo Rossi - Home on 25/10/21.
//

import XCTest
import Stargazers

class CodableStargazersStore {
    func retrieve(from repository: LocalRepository, completion: @escaping StargazersStore.RetrieveCompletion) {
        completion(.success([]))
    }
}

class CodableStargazersStoreTests: XCTestCase {

    func test_retrieve_deliversNoResultsOnEmptyCache() {
        let sut = CodableStargazersStore()
        let exp = expectation(description: "Wait for retrieve completion")
        
        sut.retrieve(from: LocalRepository(name: "any", owner: "any")) { result in
            switch result {
            case let .success(receivedStargazers):
                XCTAssertEqual(receivedStargazers, [])
            default:
                XCTFail("Expected success, got \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmtpyCache() {
        let sut = CodableStargazersStore()
        let exp = expectation(description: "Wait for retrieve completion")
        
        sut.retrieve(from: LocalRepository(name: "any", owner: "any")) { firstResult in
            sut.retrieve(from: LocalRepository(name: "any", owner: "any")) { secondResult in
                switch (firstResult, secondResult) {
                case let (.success(firstStargazers), .success(secondStargazers)):
                    XCTAssertEqual(firstStargazers, [])
                    XCTAssertEqual(secondStargazers, [])
                default:
                    XCTFail("Expected both results to be successful and empty, got \(firstResult) and \(secondResult) instead")
                }
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 1.0)
    }

}
