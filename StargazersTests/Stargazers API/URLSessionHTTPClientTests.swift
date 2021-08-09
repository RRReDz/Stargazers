//
//  URLSessionHTTPClientTests.swift
//  StargazersTests
//
//  Created by Riccardo Rossi - Home on 09/08/21.
//

import XCTest
import Stargazers

class URLSessionHTTPClientTests: XCTestCase {
    
    func test_get_deliversFailureOnRequestError() {
        let sut = makeSUT()
        let error = anyNSError()
        let url = anyURL()
        
        URLProtocolStub.registerClass(URLProtocolStub.self)
        URLProtocolStub.stub(url: url, error: error)

        let exp = expectation(description: "Wait for get completion")
        sut.get(from: url) { result in
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError.domain, error.domain)
                XCTAssertEqual(receivedError.code, error.code)
            default:
                XCTFail("Expected failure with error \(error), got \(result) instead")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
        
        URLProtocolStub.unregisterClass(URLProtocolStub.self)
    }
    
    func test_get_deliversSuccessOnRequestDeliveredWithHTTPResponseAndData() {
        let sut = makeSUT()
        let error = anyNSError()
        let url = anyURL()
        let data = "any data".data(using: .utf8)
        let response = HTTPURLResponse(url: url, statusCode: 300, httpVersion: nil, headerFields: nil)!
        
        URLProtocolStub.registerClass(URLProtocolStub.self)
        URLProtocolStub.stub(url: url, data: data, response: response)

        let exp = expectation(description: "Wait for get completion")
        sut.get(from: url) { result in
            switch result {
            case let .success((receivedData, receivedResponse)):
                XCTAssertEqual(receivedData, data)
                XCTAssertEqual(receivedResponse.url, response.url)
                XCTAssertEqual(receivedResponse.statusCode, response.statusCode)
                XCTAssertEqual(receivedResponse.mimeType, response.mimeType)
            default:
                XCTFail("Expected failure with error \(error), got \(result) instead")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
        
        URLProtocolStub.unregisterClass(URLProtocolStub.self)
    }
    
    //MARK: - Utils
    private class URLProtocolStub: URLProtocol {
        private struct Stub {
            let data: Data?
            let response: HTTPURLResponse?
            let error: Error?
        }
        
        private static var stubs = [URL: Stub]()
        
        static func stub(url: URL, data: Data? = nil, response: HTTPURLResponse? = nil, error: Error? = nil) {
            stubs[url] = Stub(data: data, response: response, error: error)
        }
        
        // Determins if this kind of protocol can handle the request for the given request.
        override class func canInit(with request: URLRequest) -> Bool {
            guard let requestURL = request.url else { return false }
            return stubs[requestURL] != nil
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }

        override func startLoading() {
            guard
                let requestURL = request.url,
                let stub = URLProtocolStub.stubs[requestURL]
            else { return }
            
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            if let data = stub.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = stub.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }

        override func stopLoading() {
            client?.urlProtocolDidFinishLoading(self)
        }
    }
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> URLSessionHTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeak(sut, file: file, line: line)
        return sut
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

}
