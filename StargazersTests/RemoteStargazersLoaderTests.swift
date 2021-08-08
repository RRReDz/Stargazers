//
//  RemoteStargazersLoaderTests.swift
//  StargazersTests
//
//  Created by Riccardo Rossi - Home on 08/08/21.
//

import XCTest

final class RemoteStargazersLoader {
    func load() {
        HTTPClient.shared.get(from: URL(string: "http://a-url.com")!)
    }
}

class HTTPClient {
    static var shared = HTTPClient()
    
    func get(from url: URL) {}
}

class HTTPClientSpy: HTTPClient {
    var requestedURLs = [URL]()
    
    override func get(from url: URL) {
        requestedURLs.append(url)
    }
}

class RemoteStargazersLoaderTests: XCTestCase {
    func test_init_doesNotRequestDataFromURL() {
        let spy = HTTPClientSpy()
        HTTPClient.shared = spy
        _ = RemoteStargazersLoader()
        
        XCTAssertEqual(spy.requestedURLs, [])
    }
    
    func test_load_doesRequestDataFromURL() {
        let spy = HTTPClientSpy()
        HTTPClient.shared = spy
        let url = URL(string: "http://a-url.com")!
        let sut = RemoteStargazersLoader()
        
        sut.load()
        
        XCTAssertEqual(spy.requestedURLs, [url])
    }
}
