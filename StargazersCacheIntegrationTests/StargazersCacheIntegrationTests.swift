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
        let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(String(describing: StargazersCacheIntegrationTests.self)).store")
        try? FileManager.default.removeItem(at: url)
    }
    
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
    
    func test_load_deliversStargazersSavedOnASeparateInstance() throws {
        let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(String(describing: StargazersCacheIntegrationTests.self)).store")
        let store = CodableStargazersStore(storeURL: url)
        let saveSut = LocalStargazersLoader(store: store)
        let loadSut = LocalStargazersLoader(store: store)
        
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
}
