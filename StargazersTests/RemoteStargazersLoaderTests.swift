//
//  RemoteStargazersLoaderTests.swift
//  StargazersTests
//
//  Created by Riccardo Rossi - Home on 08/08/21.
//

import XCTest

final class RemoteStargazersLoader {
    
}

class HTTPClient {
    var requestedURL = [URL]()
}

class RemoteStargazersLoaderTests: XCTestCase {
    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClient()
        _ = RemoteStargazersLoader()
        
        XCTAssertEqual(client.requestedURL, [])
    }
}
