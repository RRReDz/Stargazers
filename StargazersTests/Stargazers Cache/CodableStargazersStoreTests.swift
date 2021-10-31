//
//  CodableStargazersStoreTests.swift
//  StargazersTests
//
//  Created by Riccardo Rossi - Home on 25/10/21.
//

import XCTest
import Stargazers

class CodableStargazersStore {
    private struct CodableStargazer: Codable {
        private let id: String
        private let username: String
        private let avatarURL: URL
        private let detailURL: URL
        
        init(_ localStargazer: LocalStargazer) {
            id = localStargazer.id
            username = localStargazer.username
            avatarURL = localStargazer.avatarURL
            detailURL = localStargazer.detailURL
        }
        
        var local: LocalStargazer {
            return LocalStargazer(
                id: id,
                username: username,
                avatarURL: avatarURL,
                detailURL: detailURL)
        }
    }
    
    private let storeURL: URL
    
    init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    func retrieve(from repository: LocalRepository, completion: @escaping StargazersStore.RetrieveCompletion) {
        enum InnerError: Error {
            case invalidURL
        }
        
        do {
            guard let data = try? Data(contentsOf: storeURL) else { throw InnerError.invalidURL }
            let stargazers = try JSONDecoder().decode([CodableStargazer].self, from: data)
            completion(.success(stargazers.map { $0.local }))
        } catch InnerError.invalidURL {
            completion(.success([]))
        } catch {
            completion(.failure(error))
        }
    }
    
    func insert(
        _ stargazers: [LocalStargazer],
        for repository: LocalRepository,
        completion: @escaping StargazersStore.InsertCompletion
    ) {
        let data = try! JSONEncoder().encode(stargazers.map(CodableStargazer.init))
        try! data.write(to: storeURL)
        completion(.success(()))
    }
}

class CodableStargazersStoreTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }

    func test_retrieve_deliversNoResultsOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toRetrieve: .success([]))
    }
    
    func test_retrieve_hasNoSideEffectsOnEmtpyCache() {
        let sut = makeSUT()
        
        expect(sut, toRetrieveTwice: .success([]))
    }
    
    func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues() {
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
    
    func test_retrieve_returnsErrorWhenDataInvalid() throws {
        let data = "invalid data".data(using: .utf8)!
        try data.write(to: testSpecificStoreURL())
        
        expect(makeSUT(), toRetrieve: .failure(anyNSError()))
    }
    
    func test_retrieve_hasNoSideEffectsOnInvalidCacheData() throws {
        let data = "invalid data".data(using: .utf8)!
        try data.write(to: testSpecificStoreURL())
        
        expect(makeSUT(), toRetrieveTwice: .failure(anyNSError()))
    }

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CodableStargazersStore {
        let sut = CodableStargazersStore(storeURL: testSpecificStoreURL())
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func testSpecificStoreURL() -> URL {
        let cachesDirectoryURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return cachesDirectoryURL.appendingPathComponent("\(String(describing: self)).store")
    }
    
    private func expect(
        _ sut: CodableStargazersStore,
        toRetrieve expectedResult: Result<[LocalStargazer], Error>,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for retrieve completion")
        
        sut.retrieve(from: LocalRepository(name: "any", owner: "any")) { receivedResult in
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
        _ sut: CodableStargazersStore,
        toRetrieveTwice expectedResult: Result<[LocalStargazer], Error>,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }
    
    private func insert(
        stargazers: [LocalStargazer],
        to sut: CodableStargazersStore,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for insert completion")
        
        sut.insert(stargazers, for: LocalRepository(name: "any", owner: "any")) { insertionResult in
            XCTAssertNotNil(
                try? insertionResult.get(),
                "Expected stargazers to be inserted successfully",
                file: file,
                line: line
            )
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
}
