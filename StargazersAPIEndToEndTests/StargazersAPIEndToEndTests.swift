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
        let url = URL(string: "https://api.github.com/repos/apple/swift/stargazers")!
        let loader = makeLoader(for: url)
        
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
    
    private func makeLoader(for url: URL) -> RemoteStargazersLoader {
        let client = URLSessionHTTPClient()
        let loader = RemoteStargazersLoader(client: client, url: url)
        trackForMemoryLeak(client)
        trackForMemoryLeak(loader)
        return loader
    }
    
}
