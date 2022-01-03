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
        
        expect(sut, toLoad: [])
    }
    
    func test_load_deliversStargazersSavedOnASeparateInstance() throws {
        let saveSut = makeSUT()
        let loadSut = makeSUT()
        
        let stargazers = [anyStargazer()]
        
        expect(saveSut, toSave: stargazers)
        expect(loadSut, toLoad: stargazers)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> LocalStargazersLoader {
        let storeURL = testSpecificStoreURL()
        let store = CodableStargazersStore(storeURL: storeURL)
        let sut = LocalStargazersLoader(store: store)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        return sut
    }
    
    private func expect(
        _ sut: LocalStargazersLoader,
        toLoad expectedStargazers: [Stargazer],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for load completion")
        sut.load(from: anyRepository()) { result in
            switch result {
            case let .success(receivedStargazers):
                XCTAssertEqual(expectedStargazers, receivedStargazers, file: file, line: line)
            default:
                XCTFail("Expected success with empty stargazers, got \(result) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func expect(
        _ sut: LocalStargazersLoader,
        toSave stargazers: [Stargazer],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let saveExp = expectation(description: "Wait for save completion")
        sut.save(stargazers, for: anyRepository()) { result in
            if case .failure = result {
                XCTFail("Expected saving successfully, got \(result) instead", file: file, line: line)
            }
            saveExp.fulfill()
        }
        wait(for: [saveExp], timeout: 1.0)
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
