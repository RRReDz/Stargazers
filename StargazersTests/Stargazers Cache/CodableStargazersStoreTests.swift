//
//  CodableStargazersStoreTests.swift
//  StargazersTests
//
//  Created by Riccardo Rossi - Home on 25/10/21.
//

import XCTest
import Stargazers

class CodableStargazersStoreTests: XCTestCase {
    
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
        let stargazers = uniqueStargazers().local
        insert(stargazers: stargazers, to: sut)
        
        expect(sut, toRetrieve: .success(stargazers))
    }
    
    func test_retrieve_hasNoSideEffectOnNonEmptyCache() {
        let sut = makeSUT()
        let stargazers = uniqueStargazers().local
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
        let previousStargazers = uniqueStargazers().local
        insert(stargazers: previousStargazers, to: sut)
        
        let newStargazers = uniqueStargazers().local
        insert(stargazers: newStargazers, to: sut)
        
        expect(sut, toRetrieve: .success(newStargazers))
    }
    
    func test_insert_toNonEmptyCacheButOtherRepoDoesNotOverridePreviousRepoData() {
        let sut = makeSUT()
        let firstRepoStargazers = uniqueStargazers().local
        let firstRepo = uniqueLocalRepository()
        insert(stargazers: firstRepoStargazers, for: firstRepo, to: sut)
        
        let secondRepoStargazers = uniqueStargazers().local
        insert(stargazers: secondRepoStargazers, for: uniqueLocalRepository(), to: sut)
        
        expect(sut, toRetrieve: .success(firstRepoStargazers), for: firstRepo)
    }
    
    func test_insert_deliversErrorOnStoreURLWithNoWritePermissions() throws {
        let storeURL = noWritePermissionsURL()
        let sut = makeSUT(storeURL: storeURL)
        
        let stargazers = uniqueStargazers().local
        let insertionResult = insert(stargazers: stargazers, to: sut)
        
        XCTAssertThrowsError(try insertionResult.get())
    }
    
    func test_insert_deliversErrorOnInvalidStoreURL() throws {
        let storeURL = URL(string: "invalid://store-url")!
        let sut = makeSUT(storeURL: storeURL)
        
        let stargazers = uniqueStargazers().local
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
        insert(stargazers: uniqueStargazers().local, to: sut)
        
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
        let firstRepoStargazers = uniqueStargazers().local
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
        
        sut.insert(uniqueStargazers().local, for: uniqueLocalRepository()) { _ in
            expectations[0].fulfill()
        }
        
        sut.deleteStargazers(for: uniqueLocalRepository()) { _ in
            expectations[1].fulfill()
        }
        
        sut.insert(uniqueStargazers().local, for: uniqueLocalRepository()) { _ in
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
    
    private func expect(
        _ sut: StargazersStore,
        toRetrieve expectedResult: Result<[LocalStargazer], Error>,
        for repository: LocalRepository? = nil,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for retrieve completion")
        
        sut.retrieve(from: repository ?? useCaseRepository().local) { receivedResult in
            switch (expectedResult, receivedResult) {
            case let (.success(expectedStargazers), .success(receivedStargazers)):
                XCTAssertEqual(expectedStargazers, receivedStargazers, file: file, line: line)
            case (.failure, .failure):
                break
            default:
                XCTFail(
                    "Expected results to be the same, expected \(expectedResult) got \(receivedResult) instead",
                    file: file,
                    line: line
                )
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func expect(
        _ sut: StargazersStore,
        toRetrieveTwice expectedResult: Result<[LocalStargazer], Error>,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }
    
    @discardableResult
    private func insert(
        stargazers: [LocalStargazer],
        for repository: LocalRepository? = nil,
        to sut: StargazersStore,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Result<Void, Error> {
        let exp = expectation(description: "Wait for insert completion")
        var result: Result<Void, Error>!
        
        sut.insert(stargazers, for: repository ?? useCaseRepository().local) {
            result = $0
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        return result
    }
    
    @discardableResult
    private func deleteStargazers(for repository: LocalRepository? = nil, in sut: StargazersStore) -> Result<Void, Error> {
        let exp = expectation(description: "Wait for stargazers delete completion")
        
        var result: Result<Void, Error>!
        sut.deleteStargazers(for: repository ?? useCaseRepository().local) {
            result = $0
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        return result
    }
    
    private func uniqueLocalRepository() -> LocalRepository {
        return LocalRepository(name: UUID().uuidString, owner: UUID().uuidString)
    }
    
}
