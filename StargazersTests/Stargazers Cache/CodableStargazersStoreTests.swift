//
//  CodableStargazersStoreTests.swift
//  StargazersTests
//
//  Created by Riccardo Rossi - Home on 25/10/21.
//

import XCTest
import Stargazers

class CodableStargazersStore {
    private let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("stargazers.store")
    
    func retrieve(from repository: LocalRepository, completion: @escaping StargazersStore.RetrieveCompletion) {
        guard let data = try? Data(contentsOf: storeURL) else {
            completion(.success([]))
            return
        }
        let stargazers = try! JSONDecoder().decode([LocalStargazer].self, from: data)
        completion(.success(stargazers))
    }
    
    func insert(
        _ stargazers: [LocalStargazer],
        for repository: LocalRepository,
        completion: @escaping StargazersStore.InsertCompletion
    ) {
        let data = try! JSONEncoder().encode(stargazers)
        try! data.write(to: storeURL)
        completion(.success(()))
    }
}

class CodableStargazersStoreTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("stargazers.store")
        try? FileManager.default.removeItem(at: storeURL)
    }

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
    
    func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues() {
        let sut = CodableStargazersStore()
        let stargazers = uniqueStargazers().local
        let repository = useCaseRepository().local
        
        let exp = expectation(description: "Wait for retrieve completion")
        
        sut.insert(stargazers, for: repository) { insertionResult in
            XCTAssertNotNil(try? insertionResult.get(), "Expected stargazers to be inserted successfully")
            sut.retrieve(from: repository) { retrievalResult in
                switch retrievalResult {
                case let .success(retrievedStargazers):
                    XCTAssertEqual(stargazers, retrievedStargazers)
                default:
                    XCTFail("Expected success, got \(retrievalResult) instead")
                }
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 1.0)
    }

}
