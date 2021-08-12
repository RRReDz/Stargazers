//
//  StargazersAPIEndToEndTests.swift
//  StargazersAPIEndToEndTests
//
//  Created by Riccardo Rossi - Home on 12/08/21.
//

import XCTest
import Stargazers

class StargazersAPIEndToEndTests: XCTestCase {
    
    func test_loadingStargazers_completesSuccessfully() {
        let loader = makeStargazersLoader()
        
        let exp = expectation(description: "Wait for load completion")
        loader.load { receivedResult in
            switch receivedResult {
            case .success:
                break
            case let .failure(error):
                XCTFail("Expected success, got failure with \(error) instead.")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
    }
    
    private func makeStargazersLoader(file: StaticString = #filePath, line: UInt = #line) -> RemoteStargazersLoader {
        let url = URL(string: "https://api.github.com/repos/octocat/hello-world/stargazers")!
        let client = URLSessionHTTPClient()
        let loader = RemoteStargazersLoader(url: url, client: client)
        trackForMemoryLeak(client, file: file, line: line)
        trackForMemoryLeak(loader, file: file, line: line)
        return loader
    }
    
}
