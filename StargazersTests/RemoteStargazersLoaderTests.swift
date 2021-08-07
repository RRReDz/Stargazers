//
//  RemoteStargazersLoaderTests.swift
//  StargazersTests
//
//  Created by Riccardo Rossi - Home on 08/08/21.
//

import XCTest

final class RemoteStargazersLoader {
    func load() {
        HTTPClient.shared.requestedURL = [URL(string: "http://a-url.com")!]
    }
}

class HTTPClient {
    private init() {}
    
    static let shared = HTTPClient()
    
    var requestedURL = [URL]()
}

class RemoteStargazersLoaderTests: XCTestCase {
    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClient.shared
        _ = RemoteStargazersLoader()
        
        XCTAssertEqual(client.requestedURL, [])
    }
    
    func test_load_doesRequestDataFromURL() {
        let client = HTTPClient.shared
        let url = URL(string: "http://a-url.com")!
        let sut = RemoteStargazersLoader()
        
        sut.load()
        
        XCTAssertEqual(client.requestedURL, [url])
    }
}
