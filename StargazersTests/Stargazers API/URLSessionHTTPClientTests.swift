//
//  URLSessionHTTPClientTests.swift
//  StargazersTests
//
//  Created by Riccardo Rossi - Home on 09/08/21.
//

import XCTest
import Stargazers

class URLSessionHTTPClientTests: XCTestCase {
    
    override func setUp() {
        URLProtocolStub.startInterceptingRequests()
    }
    
    override func tearDown() {
        URLProtocolStub.stopInterceptingRequests()
    }
    
    func test_get_deliversFailureOnRequestError() {
        let sut = makeSUT()
        let error = anyNSError()
        let url = anyURL()
        
        URLProtocolStub.stub(url: url, data: nil, response: nil, error: error)

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
    }
    
    func test_get_deliversSuccessOnRequestDeliveredWithHTTPResponseAndData() {
        let sut = makeSUT()
        let error = anyNSError()
        let url = anyURL()
        let data = "any data".data(using: .utf8)
        let response = HTTPURLResponse(url: url, statusCode: 300, httpVersion: nil, headerFields: nil)!
        
        URLProtocolStub.stub(url: url, data: data, response: response, error: nil)

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
    }
    
    //MARK: - Utils
    private class URLProtocolStub: URLProtocol {
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        private static var stubs = [URL: Stub]()
        
        static func stub(url: URL, data: Data? = nil, response: HTTPURLResponse? = nil, error: Error? = nil) {
            stubs[url] = Stub(data: data, response: response, error: error)
        }
        
        static func startInterceptingRequests() {
            Self.registerClass(Self.self)
        }
        
        static func stopInterceptingRequests() {
            Self.unregisterClass(Self.self)
            URLProtocolStub.stubs = [:]
        }
        
        // Determins if this kind of protocol can handle the request for the given request.
        override class func canInit(with request: URLRequest) -> Bool {
            guard let requestURL = request.url else { return false }
            return stubs[requestURL] != nil
        }
        
        // Makes a certain request canonical (sinonym for unique) for the implemented protocol
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        // Starts protocol-specific loading of the request.
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
        
        // Stops protocol-specific loading of the request.
        override func stopLoading() {
            URLProtocolStub.stubs = [:]
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
