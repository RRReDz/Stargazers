//
//  RemoteStargazersLoaderTests.swift
//  StargazersTests
//
//  Created by Riccardo Rossi - Home on 08/08/21.
//

import XCTest
import Stargazers

class RemoteStargazersLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT(for: anyURL())
        
        XCTAssertEqual(client.requestedURLs, [])
    }
    
    func test_load_doesRequestDataFromURL() {
        let url = anyURL()
        let (sut, client) = makeSUT(for: url)
        
        sut.load() { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_doesRequestDataFromURLTwice() {
        let url = anyURL()
        let (sut, client) = makeSUT(for: url)
        
        sut.load() { _ in }
        sut.load() { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversConnectivityErrorOnClientError() {
        let (sut, client) = makeSUT(for: anyURL())
        
        assert(that: sut, completesWith: .connectivity, on: {
            client.complete(with: NSError(domain: "any", code: -1))
        })
    }
    
    func test_load_deliversInvalidDataErrorOnClientNon200HTTPResponse() {
        let (sut, client) = makeSUT(for: anyURL())
        let samples = [199, 201, 250, 300, 400, 404, 500]
        
        samples.enumerated().forEach { index, code in
            assert(that: sut, completesWith: .invalidData, on: {
                client.complete(statusCode: code, at: index)
            })
        }
    }
    
    func test_load_deliversInvalidDataErrorOnClient200HTTPResponseAndInvalidData() {
        let invalidData = "any invalid data".data(using: .utf8)!
        let (sut, client) = makeSUT(for: anyURL())
        
        assert(that: sut, completesWith: .invalidData, on: {
            client.complete(statusCode: 200, data: invalidData)
        })
    }
    
    private func makeSUT(for url: URL) -> (RemoteStargazersLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteStargazersLoader(client: client, url: url)
        return (sut, client)
    }
    
    private func assert(
        that sut: RemoteStargazersLoader,
        completesWith expectedError: RemoteStargazersLoader.Error,
        on action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        var capturedErrors = [RemoteStargazersLoader.Error]()
        sut.load { capturedErrors.append($0) }
        action()
        XCTAssertEqual(capturedErrors, [expectedError], file: file, line: line)
    }
    
    private func anyURL() -> URL {
        URL(string: "http://any-url.com")!
    }
    
    class HTTPClientSpy: HTTPClient {
        private var messages = [(url: URL, completion: (HTTPClient.CompletionResult) -> Void)]()
        var requestedURLs: [URL] {
            messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping (HTTPClient.CompletionResult) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(statusCode: Int, data: Data = Data(), at index: Int = 0) {
            let httpResponse = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: nil)!
            messages[index].completion(.success(httpResponse))
        }
    }
    
}
