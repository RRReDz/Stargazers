//
//  URLSessionHTTPClientTests.swift
//  StargazersTests
//
//  Created by Riccardo Rossi - Home on 09/08/21.
//

import XCTest

final class URLSessionHTTPClient {
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(from url: URL) {
        let task = session.dataTask(with: url) { _, _, _ in }
        task.resume()
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
        
        session.stub(task, for: url)
        
        sut.get(from: url)
        
        XCTAssertEqual(task.resumesCallCount, 1)
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
        var requestedURLs = [URL]()
        private var stubs = [URL: URLSessionDataTask]()
        
        override init() {}
        
        private class FakeURLSessionDataTask: URLSessionDataTask {
            override func resume() {}
        }
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            requestedURLs.append(url)
            
            return stubs[url] ?? FakeURLSessionDataTask()
        }
        
        func stub(_ task: URLSessionDataTask, for url: URL) {
            stubs[url] = task
        }
    }

    final class URLSessionDataTaskSpy: URLSessionDataTask {
        var resumesCallCount: Int = 0
        
        override func resume() {
            resumesCallCount += 1
        }
    }

}
