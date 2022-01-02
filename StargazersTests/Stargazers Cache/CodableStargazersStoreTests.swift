//
//  CodableStargazersStoreTests.swift
//  StargazersTests
//
//  Created by Riccardo Rossi - Home on 25/10/21.
//

import XCTest
import Stargazers

class CodableStargazersStoreTests: XCTestCase, FailableStargazersStoreSpecs {
    override func setUp() {
        super.setUp()
        
        deleteStoreArtifacts()
    }

    func test_retrieve_deliversNoResultsOnEmptyCache() {
        expect(makeSUT(), toRetrieve: .success([]))
    }
    
    func test_retrieve_hasNoSideEffectsOnEmtpyCache() {
        expect(makeSUT(), toRetrieveTwice: .success([]))
    }
    
    func test_retrieve_deliversValuesOnNonEmptyCache() {
        let sut = makeSUT()
        let stargazers = uniqueUseCaseStargazers().local
        insert(stargazers: stargazers, to: sut)
        
        expect(sut, toRetrieve: .success(stargazers))
    }
    
    func test_retrieve_hasNoSideEffectOnNonEmptyCache() {
        let sut = makeSUT()
        let stargazers = uniqueUseCaseStargazers().local
        insert(stargazers: stargazers, to: sut)
        
        expect(sut, toRetrieveTwice: .success(stargazers))
    }
    
    func test_retrieve_returnsErrorOnInvalidCacheData() throws {
        let storeURL = testSpecificStoreURL()
        try "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        
        expect(makeSUT(storeURL: storeURL), toRetrieve: .failure(anyNSError()))
    }
    
    func test_retrieve_hasNoSideEffectsOnInvalidCacheData() throws {
        let storeURL = testSpecificStoreURL()
        try "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        
        expect(makeSUT(storeURL: storeURL), toRetrieveTwice: .failure(anyNSError()))
    }
    
    func test_insert_toNonEmptyCacheOverridesPreviousData() {
        let sut = makeSUT()
        let previousStargazers = uniqueUseCaseStargazers().local
        insert(stargazers: previousStargazers, to: sut)
        
        let newStargazers = uniqueUseCaseStargazers().local
        insert(stargazers: newStargazers, to: sut)
        
        expect(sut, toRetrieve: .success(newStargazers))
    }
    
    func test_insert_toNonEmptyCacheButOtherRepoDoesNotOverridePreviousRepoData() {
        let sut = makeSUT()
        let firstRepoStargazers = uniqueUseCaseStargazers().local
        let firstRepo = uniqueLocalRepository()
        insert(stargazers: firstRepoStargazers, for: firstRepo, to: sut)
        
        let secondRepoStargazers = uniqueUseCaseStargazers().local
        insert(stargazers: secondRepoStargazers, for: uniqueLocalRepository(), to: sut)
        
        expect(sut, toRetrieve: .success(firstRepoStargazers), for: firstRepo)
    }
    
    func test_insert_deliversErrorOnStoreURLWithNoWritePermissions() throws {
        let storeURL = noWritePermissionsURL()
        let sut = makeSUT(storeURL: storeURL)
        
        let stargazers = uniqueUseCaseStargazers().local
        let insertionResult = insert(stargazers: stargazers, to: sut)
        
        XCTAssertThrowsError(try insertionResult.get())
    }
    
    func test_insert_deliversErrorOnInvalidStoreURL() throws {
        let storeURL = URL(string: "invalid://store-url")!
        let sut = makeSUT(storeURL: storeURL)
        
        let stargazers = uniqueUseCaseStargazers().local
        let insertionResult = insert(stargazers: stargazers, to: sut)
        
        XCTAssertThrowsError(try insertionResult.get())
    }
    
    func test_deleteStargazers_cacheStaysEmptyOnEmptyCache() {
        let sut = makeSUT()
        
        deleteStargazers(in: sut)
        
        expect(sut, toRetrieve: .success([]))
    }
    
    func test_deleteStargazers_leavesCacheEmptyOnNonEmptyCache() {
        let sut = makeSUT()
        insert(stargazers: uniqueUseCaseStargazers().local, to: sut)
        
        deleteStargazers(in: sut)
        
        expect(sut, toRetrieve: .success([]))
    }
    
    func test_deleteStargazers_deliversErrorOnStoreURLWithNoWritePermissions() throws {
        let storeURL = noWritePermissionsURL()
        let sut = makeSUT(storeURL: storeURL)
        
        let deletionResult = deleteStargazers(in: sut)
        
        XCTAssertThrowsError(try deletionResult.get())
    }
    
    func test_deleteStargazers_doesNotLeaveCacheEmptyForOtherRepositoryNonEmptyData() {
        let sut = makeSUT()
        let firstRepoStargazers = uniqueUseCaseStargazers().local
        let firstRepo = uniqueLocalRepository()
        insert(stargazers: firstRepoStargazers, for: firstRepo, to: sut)
        
        let secondRepo = uniqueLocalRepository()
        deleteStargazers(for: secondRepo, in: sut)
        
        expect(sut, toRetrieve: .success(firstRepoStargazers), for: firstRepo)
    }
    
    func test_sideEffects_runsSerially() {
        let sut = makeSUT()
        
        let expectations: [XCTestExpectation] = [
            expectation(description: "First insertion completion"),
            expectation(description: "Deletion completion"),
            expectation(description: "Second insertion completion")
        ]
        
        sut.insert(uniqueUseCaseStargazers().local, for: uniqueLocalRepository()) { _ in
            expectations[0].fulfill()
        }
        
        sut.deleteStargazers(for: uniqueLocalRepository()) { _ in
            expectations[1].fulfill()
        }
        
        sut.insert(uniqueUseCaseStargazers().local, for: uniqueLocalRepository()) { _ in
            expectations[2].fulfill()
        }
        
        wait(for: expectations, timeout: 1.0, enforceOrder: true)
    }
    
    // MARK: - Utils

    private func makeSUT(storeURL: URL? = nil, file: StaticString = #filePath, line: UInt = #line) -> StargazersStore {
        let sut = CodableStargazersStore(storeURL: storeURL ?? testSpecificStoreURL())
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func testSpecificStoreURL() -> URL {
        return cachesDirectoryURL().appendingPathComponent("\(String(describing: self)).store")
    }
    
    private func noWritePermissionsURL() -> URL {
        return adminApplicationDirectoryURL().appendingPathComponent("any.store")
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    
    private func cachesDirectoryURL() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    private func adminApplicationDirectoryURL() -> URL {
        FileManager.default.urls(for: .adminApplicationDirectory, in: .systemDomainMask).first!
    }
    
    private func uniqueLocalRepository() -> LocalRepository {
        return LocalRepository(name: UUID().uuidString, owner: UUID().uuidString)
    }
    
}
