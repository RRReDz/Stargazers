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
        _ = session.dataTask(with: url)
    }
}

final class URLSessionSpy: URLSession {
    var requestedURLs = [URL]()
    
    override init() {}
    
    override func dataTask(with url: URL) -> URLSessionDataTask {
        class AnyTask: URLSessionDataTask {}
        
        requestedURLs.append(url)
        
        return AnyTask()
    }
}

class URLSessionHTTPClientTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let session = URLSessionSpy()
        _ = URLSessionHTTPClient(session: session)
        
        XCTAssertEqual(session.requestedURLs, [])
    }
    
    func test_get_doesRequestDataFromURL() {
        let url = anyURL()
        let (sut, session) = makeSUT()
        
        sut.get(from: url)
        
        XCTAssertEqual(session.requestedURLs, [url])
    }
    
    func test_getTwice_doesRequestDataFromURLTwice() {
        let url = anyURL()
        let (sut, session) = makeSUT()

        sut.get(from: url)
        sut.get(from: url)

        XCTAssertEqual(session.requestedURLs, [url, url])
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

}
