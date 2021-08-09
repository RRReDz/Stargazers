//
//  URLSessionHTTPClientTests.swift
//  StargazersTests
//
//  Created by Riccardo Rossi - Home on 09/08/21.
//

import XCTest
import Stargazers

final class URLSessionHTTPClient {
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void = { _ in }) {
        session.dataTask(with: url) { _, _, error in
            error.map { completion(.failure($0)) }
        }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (_, session) = makeSUT()
        
        XCTAssertEqual(session.requestedURLs, [])
    }
    
    func test_get_resumesDataTaskWithURL() {
        let url = anyURL()
        let task = URLSessionDataTaskSpy()
        let (sut, session) = makeSUT()
        
        session.stub(url: url, task: task)
        
        sut.get(from: url)
        
        XCTAssertEqual(task.resumesCallCount, 1)
    }
    
    func test_get_deliversFailureOnRequestError() {
        let (sut, session) = makeSUT()
        let error = anyNSError()
        let url = anyURL()
        session.stub(url: url, error: error)

        let exp = expectation(description: "Wait for get completion")
        sut.get(from: url) { result in
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError, error)
            default:
                XCTFail("Expected failure with error \(error), got \(result) instead")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }
    
    //MARK: - Utils
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (URLSessionHTTPClient, URLSessionSpy) {
        let session = URLSessionSpy()
        let sut = URLSessionHTTPClient(session: session)
        trackForMemoryLeak(sut, file: file, line: line)
        trackForMemoryLeak(session, file: file, line: line)
        return (sut, session)
    }
    
    private func trackForMemoryLeak(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }
    
    private func anyURL() -> URL {
        URL(string: "http://any-url.com")!
    }
    
    private func anyNSError() -> NSError {
        NSError(domain: "any", code: -1)
    }
    
    final class URLSessionSpy: URLSession {
        private struct Stub {
            let task: URLSessionDataTask
            let error: Error?
        }
        
        var requestedURLs = [URL]()
        private var stubs = [URL: Stub]()
        
        override init() {}
        
        private class FakeURLSessionDataTask: URLSessionDataTask {
            override func resume() {}
        }
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            requestedURLs.append(url)
            guard let stub = stubs[url] else {
                fatalError("Couldn't find a stub for url \(url)")
            }
        
            completionHandler(nil, nil, stub.error)
            return stub.task
        }
        
        func stub(url: URL, task: URLSessionDataTask = FakeURLSessionDataTask(), error: Error? = nil) {
            stubs[url] = Stub(task: task, error: error)
        }
    }

    final class URLSessionDataTaskSpy: URLSessionDataTask {
        var resumesCallCount: Int = 0
        
        override func resume() {
            resumesCallCount += 1
        }
    }

}
