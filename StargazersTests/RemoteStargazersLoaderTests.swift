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
        
        assert(that: sut, completesWith: .failure(.connectivity), on: {
            client.complete(with: NSError(domain: "any", code: -1))
        })
    }
    
    func test_load_deliversInvalidDataErrorOnClientNon200HTTPResponse() {
        let (sut, client) = makeSUT(for: anyURL())
        let samples = [199, 201, 250, 300, 400, 404, 500]
        
        samples.enumerated().forEach { index, code in
            assert(that: sut, completesWith: .failure(.invalidData), on: {
                client.complete(statusCode: code, at: index)
            })
        }
    }
    
    func test_load_deliversInvalidDataErrorOnClient200HTTPResponseAndInvalidData() {
        let invalidData = "any invalid data".data(using: .utf8)!
        let (sut, client) = makeSUT(for: anyURL())
        
        assert(that: sut, completesWith: .failure(.invalidData), on: {
            client.complete(statusCode: 200, data: invalidData)
        })
    }
    
    func test_load_deliversStargazersOnClient200HTTPResponseAndValidData() throws {
        let (stargazer0, stargazer0JSON) = makeStargazer(
            id: 5946912,
            username: "any_login",
            avatarStringURL: "https://image.fake.com/u/5946912?v=4",
            userDetailStringURL: "https://api.fake.com/users/any_login")
        
        let (stargazer1, stargazer1JSON) = makeStargazer(
            id: 5946913,
            username: "another_login",
            avatarStringURL: "https://image.fake.com/u/5946913?v=4",
            userDetailStringURL: "https://api.fake.com/users/another_login")
        
        let (stargazer2, stargazer2JSON) = makeStargazer(
            id: 5946914,
            username: "last_login",
            avatarStringURL: "https://image.fake.com/u/5946914?v=4",
            userDetailStringURL: "https://api.fake.com/users/last_login")
        
        let stargazersJSON = [
            stargazer0JSON,
            stargazer1JSON,
            stargazer2JSON
        ]
        
        let stargazers = [stargazer0, stargazer1, stargazer2]
        
        let validData: Data = try JSONSerialization.data(withJSONObject: stargazersJSON)
        let (sut, client) = makeSUT(for: anyURL())
        
        assert(that: sut, completesWith: .success(stargazers), on: {
            client.complete(statusCode: 200, data: validData)
        })
    }
    
    private func makeSUT(for url: URL) -> (RemoteStargazersLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteStargazersLoader(client: client, url: url)
        return (sut, client)
    }
    
    private typealias StargazerJSON = [String: Any]
    private func makeStargazer(
        id: Int,
        username: String,
        avatarStringURL: String,
        userDetailStringURL: String
    ) -> (Stargazer, StargazerJSON) {
        let stargazer = Stargazer(
            id: id,
            username: username,
            avatarURL: URL(string: avatarStringURL)!,
            detailURL: URL(string: userDetailStringURL)!
        )
        let stargazerJSON: StargazerJSON = [
            "id": id,
            "login": username,
            "avatar_url": avatarStringURL,
            "url": userDetailStringURL
        ]
        return (stargazer, stargazerJSON)
    }
    
    private func assert(
        that sut: RemoteStargazersLoader,
        completesWith expectedResult: Result<[Stargazer], RemoteStargazersLoader.Error>,
        on action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for load completion")
        
        sut.load { receivedResult in
            switch (expectedResult, receivedResult) {
            case let (.failure(expectedError), .failure(receivedError)):
                XCTAssertEqual(expectedError, receivedError, file: file, line: line)
            case let (.success(expectedStargazers), .success(receivedStargazers)):
                XCTAssertEqual(expectedStargazers, receivedStargazers, file: file, line: line)
            default:
                XCTFail("Expected result was \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        action()
        
        wait(for: [exp], timeout: 1.0)
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
            messages[index].completion(.success((data, httpResponse)))
        }
    }
    
}
