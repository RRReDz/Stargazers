//
//  URLSessionHTTPClientTests.swift
//  StargazersTests
//
//  Created by Riccardo Rossi - Home on 09/08/21.
//

import XCTest
import Stargazers

protocol HTTPSession {
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask
}

protocol HTTPSessionTask {
    func resume()
}

final class URLSessionHTTPClient {
    private let session: HTTPSession
    
    init(session: HTTPSession) {
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
    
    final class URLSessionSpy: HTTPSession {
        private struct Stub {
            let task: HTTPSessionTask
            let error: Error?
        }
        
        var requestedURLs = [URL]()
        private var stubs = [URL: Stub]()
        
        private class FakeURLSessionDataTask: HTTPSessionTask {
            func resume() {}
        }
        
        func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask {
            requestedURLs.append(url)
            guard let stub = stubs[url] else {
                fatalError("Couldn't find a stub for url \(url)")
            }
        
            completionHandler(nil, nil, stub.error)
            return stub.task
        }
        
        func stub(url: URL, task: HTTPSessionTask = FakeURLSessionDataTask(), error: Error? = nil) {
            stubs[url] = Stub(task: task, error: error)
        }
    }

    final class URLSessionDataTaskSpy: HTTPSessionTask {
        var resumesCallCount: Int = 0
        
        func resume() {
            resumesCallCount += 1
        }
    }

}
