//
//  RemoteStargazersLoaderTests.swift
//  StargazersTests
//
//  Created by Riccardo Rossi - Home on 08/08/21.
//

import XCTest
import Stargazers

final class RemoteStargazersLoader {
    private let client: HTTPClient
    private let url: URL
    
    enum Error: Swift.Error {
        case invalidData
    }
    
    init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    func load(completion: @escaping (Swift.Error) -> Void) {
        client.get(from: url) { _ in
            completion(Error.invalidData)
        }
    }
}

protocol HTTPClient {
    func get(from url: URL, completion: @escaping (Error) -> Void)
}

class RemoteStargazersLoaderTests: XCTestCase {
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertEqual(client.requestedURLs, [])
    }
    
    func test_load_doesRequestDataFromURL() {
        let url = URL(string: "http://any-url.com")!
        let (sut, client) = makeSUT(for: url)
        
        sut.load() { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_load_deliversInvalidDataErrorOnClientError() {
        let (sut, client) = makeSUT(for: URL(string: "http://any-url.com")!)
        
        let exp = expectation(description: "Wait for load completion")
        sut.load { error in
            XCTAssertEqual(error as? RemoteStargazersLoader.Error, .invalidData)
            exp.fulfill()
        }
        
        client.complete(with: NSError(domain: "any", code: -1))
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func makeSUT(for url: URL = URL(string: "http://a-default-url.com")!) -> (RemoteStargazersLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteStargazersLoader(client: client, url: url)
        return (sut, client)
    }
    
    class HTTPClientSpy: HTTPClient {
        var requestedURLs = [URL]()
        var completions = [(Error) -> Void]()
        
        func get(from url: URL, completion: @escaping (Error) -> Void) {
            requestedURLs.append(url)
            completions.append(completion)
        }
        
        func complete(with error: Error, at index: Int = 0) {
            completions[index](error)
        }
    }
}
