//
//  URLSessionHTTPClientTests.swift
//  StargazersTests
//
//  Created by Riccardo Rossi - Home on 09/08/21.
//

import XCTest

final class URLSessionHTTPClient {
    private let session: URLSessionSpy
    
    init(session: URLSessionSpy) {
        self.session = session
    }
}

final class URLSessionSpy {
    var requestedURLs = [URL]()
}

class URLSessionHTTPClientTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let session = URLSessionSpy()
        _ = URLSessionHTTPClient(session: session)
        
        XCTAssertEqual(session.requestedURLs, [])
    }

}
