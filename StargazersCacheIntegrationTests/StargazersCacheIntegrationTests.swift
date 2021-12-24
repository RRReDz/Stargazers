//
//  StargazersCacheIntegrationTests.swift
//  StargazersCacheIntegrationTests
//
//  Created by Riccardo Rossi - Home on 24/12/21.
//

import XCTest
import Stargazers

class StargazersCacheIntegrationTests: XCTestCase {
    
    func test_load_deliversNoStargazersOnEmtpyCache() throws {
        let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(String(describing: StargazersCacheIntegrationTests.self)).store")
        let store = CodableStargazersStore(storeURL: url)
        let sut = LocalStargazersLoader(store: store)
        let repository = Repository(name: "Any repository", owner: "Any owner")
        
        let exp = expectation(description: "Wait for load completion")
        sut.load(from: repository) { result in
            switch result {
            case let .success(stargazers):
                XCTAssertEqual([], stargazers)
            default:
                XCTFail("Expected success with empty stargazers, got \(result) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
}
