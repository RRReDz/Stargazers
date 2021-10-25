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

}
