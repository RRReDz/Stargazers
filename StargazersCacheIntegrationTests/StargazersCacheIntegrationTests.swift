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
    
    func test_load_deliversStargazersForRepositorySavedOnSeparateInstances() throws {
        let firstRepoSaveSut = makeSUT()
        let secondRepoSaveSut = makeSUT()
        let loadSut = makeSUT()
        
        let firstRepo = uniqueRepository()
        let secondRepo = uniqueRepository()
        let firstRepoStargazers = uniqueStargazers()
        let secondRepoStargazers = uniqueStargazers()
        
        expect(firstRepoSaveSut, toSave: firstRepoStargazers, for: firstRepo)
        
        expect(loadSut, toLoad: firstRepoStargazers, for: firstRepo)
        expect(loadSut, toLoad: [], for: secondRepo)
        
        expect(secondRepoSaveSut, toSave: secondRepoStargazers, for: secondRepo)
        
        expect(loadSut, toLoad: firstRepoStargazers, for: firstRepo)
        expect(loadSut, toLoad: secondRepoStargazers, for: secondRepo)
    }
    
    func test_save_overridesStargazersForRepositorySavedOnSeparateInstances() throws {
        let firstRepoSaveSut = makeSUT()
        let secondRepoSaveSut = makeSUT()
        let loadSut = makeSUT()
        
        let firstRepo = uniqueRepository()
        let secondRepo = uniqueRepository()
        let firstStargazers = uniqueStargazers()
        let latestStargazers = uniqueStargazers()
        
        expect(firstRepoSaveSut, toSave: firstStargazers, for: firstRepo)
        
        expect(loadSut, toLoad: firstStargazers, for: firstRepo)
        expect(loadSut, toLoad: [], for: secondRepo)
        
        expect(secondRepoSaveSut, toSave: firstStargazers, for: secondRepo)
        
        expect(loadSut, toLoad: firstStargazers, for: firstRepo)
        expect(loadSut, toLoad: firstStargazers, for: secondRepo)
        
        expect(firstRepoSaveSut, toSave: latestStargazers, for: firstRepo)
        
        expect(loadSut, toLoad: latestStargazers, for: firstRepo)
        expect(loadSut, toLoad: firstStargazers, for: secondRepo)
        
        expect(secondRepoSaveSut, toSave: latestStargazers, for: secondRepo)
        
        expect(loadSut, toLoad: latestStargazers, for: firstRepo)
        expect(loadSut, toLoad: latestStargazers, for: secondRepo)
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
        for repository: Repository? = nil,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for load completion")
        sut.load(from: repository ?? anyRepository()) { result in
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
        for repository: Repository? = nil,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let saveExp = expectation(description: "Wait for save completion")
        sut.save(stargazers, for: repository ?? anyRepository()) { result in
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
