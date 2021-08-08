//
//  RemoteStargazersLoaderTests.swift
//  StargazersTests
//
//  Created by Riccardo Rossi - Home on 08/08/21.
//

import XCTest

final class RemoteStargazersLoader {
    private let client: HTTPClient
    private let url: URL
    
    init(client: HTTPClient, url: URL = URL(string: "http://a-default-url.com")!) {
        self.client = client
        self.url = url
    }
    
    func load() {
        client.get(from: url)
    }
}

protocol HTTPClient {
    func get(from url: URL)
}

class HTTPClientSpy: HTTPClient {
    var requestedURLs = [URL]()
    
    func get(from url: URL) {
        requestedURLs.append(url)
    }
}

class RemoteStargazersLoaderTests: XCTestCase {
    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClientSpy()
        _ = RemoteStargazersLoader(client: client)
        
        XCTAssertEqual(client.requestedURLs, [])
    }
    
    func test_load_doesRequestDataFromURL() {
        let client = HTTPClientSpy()
        let url = URL(string: "http://any-url.com")!
        let sut = RemoteStargazersLoader(client: client, url: url)
        
        sut.load()
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
}
