//
//  StargazersStoreSpecs+Helpers.swift
//  StargazersTests
//
//  Created by Riccardo Rossi - Home on 29/11/21.
//

import XCTest
import Stargazers

extension StargazersStoreSpecs where Self: XCTestCase {
    func expect(
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
    
    func expect(
        _ sut: StargazersStore,
        toRetrieveTwice expectedResult: Result<[LocalStargazer], Error>,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }
    
    @discardableResult
    func insert(
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
    func deleteStargazers(for repository: LocalRepository? = nil, in sut: StargazersStore) -> Result<Void, Error> {
        let exp = expectation(description: "Wait for stargazers delete completion")
        
        var result: Result<Void, Error>!
        sut.deleteStargazers(for: repository ?? useCaseRepository().local) {
            result = $0
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        return result
    }
}
