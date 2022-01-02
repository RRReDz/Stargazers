//
//  StargazersCacheIntegrationTests.swift
//  StargazersCacheIntegrationTests
//
//  Created by Riccardo Rossi - Home on 24/12/21.
//

import XCTest
import Stargazers

class StargazersCacheIntegrationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        deleteStoreArtifacts()
    }
    
    func test_load_deliversNoStargazersOnEmtpyCache() throws {
        let sut = makeSUT()
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
    
    func test_load_deliversStargazersSavedOnASeparateInstance() throws {
        let saveSut = makeSUT()
        let loadSut = makeSUT()
        
        let repository = Repository(name: "Any repository", owner: "Any owner")
        let insertedStargazers = [
            Stargazer(
                id: UUID().uuidString,
                username: "Any username",
                avatarURL: URL(string: "any-avatar-url.com")!,
                detailURL: URL(string: "any-detail-url.com")!
            ),
            Stargazer(
                id: UUID().uuidString,
                username: "Another username",
                avatarURL: URL(string: "another-avatar-url.com")!,
                detailURL: URL(string: "another-detail-url.com")!
            )
        ]
        
        let saveExp = expectation(description: "Wait for save completion")
        saveSut.save(insertedStargazers, for: repository) { result in
            switch result {
            case .success:
                break
            default:
                XCTFail("Expected saving successfully, got \(result) instead")
            }
            saveExp.fulfill()
        }
        wait(for: [saveExp], timeout: 1.0)
        
        let loadExp = expectation(description: "Wait for load completion")
        loadSut.load(from: repository) { result in
            switch result {
            case let .success(receivedStargazers):
                XCTAssertEqual(insertedStargazers, receivedStargazers)
            default:
                XCTFail("Expected success with empty stargazers, got \(result) instead")
            }
            loadExp.fulfill()
        }
        
        wait(for: [loadExp], timeout: 1.0)
    }
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> LocalStargazersLoader {
        let storeURL = testSpecificStoreURL()
        let store = CodableStargazersStore(storeURL: storeURL)
        let sut = LocalStargazersLoader(store: store)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        return sut
    }
    
    private func cachesDirectoryURL() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    private func testSpecificStoreURL() -> URL {
        return cachesDirectoryURL().appendingPathComponent("\(String(describing: self)).store")
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
}