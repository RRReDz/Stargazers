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
        super.setUp()
        URLProtocolStub.startInterceptingRequests()
    }
    
    override func tearDown() {
        super.tearDown()
        URLProtocolStub.stopInterceptingRequests()
    }
    
    func test_getFromURL_requestsCorrectURLAndMethod() {
        let url = anyURL()
        
        let exp = expectation(description: "Wait for observeRequests gets called")
        URLProtocolStub.observeRequests = { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        makeSUT().get(from: url)
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_get_deliversFailureOnRequestError() {
        let error = anyNSError()
        let receivedError = resultErrorFor(data: nil, response: nil, error: error)
        
        let receivedNSError = receivedError as NSError?
        XCTAssertEqual(receivedNSError?.domain, error.domain)
        XCTAssertEqual(receivedNSError?.code, error.code)
    }
    
    func test_get_deliversSuccessOnRequestDeliveredWithHTTPResponseAndData() {
        let error = anyNSError()
        let url = anyURL()
        let data = "any data".data(using: .utf8)
        let response = HTTPURLResponse(url: url, statusCode: 300, httpVersion: nil, headerFields: nil)!
        
        URLProtocolStub.stub(data: data, response: response, error: nil)

        let exp = expectation(description: "Wait for get completion")
        makeSUT().get(from: url) { result in
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
    
    func test_get_deliversFailureOnAllNilValues() {
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
    }
    
    //MARK: - Utils
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> URLSessionHTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeak(sut, file: file, line: line)
        return sut
    }
    
    private func resultErrorFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        URLProtocolStub.stub(data: data, response: response, error: error)
        let exp = expectation(description: "Wait for get completion")
        
        var capturedError: Error?
        makeSUT(file: file, line: line).get(from: anyURL()) { result in
            switch result {
            case let .failure(error):
                capturedError = error
            default:
                XCTFail("Expected failure, got \(result) instead", file: file, line: line)
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
        
        return capturedError
    }
    
    private func anyURL() -> URL {
        URL(string: "http://any-url.com")!
    }
    
    private func anyNSError() -> NSError {
        NSError(domain: "any", code: -1)
    }
    
    private class URLProtocolStub: URLProtocol {
        private static var stub: Stub?
        static var observeRequests: ((URLRequest) -> Void)?
        
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        static func stub(data: Data? = nil, response: URLResponse? = nil, error: Error? = nil) {
            stub = Stub(data: data, response: response, error: error)
        }
        
        static func startInterceptingRequests() {
            Self.registerClass(Self.self)
        }
        
        static func stopInterceptingRequests() {
            Self.unregisterClass(Self.self)
            URLProtocolStub.stub = nil
            URLProtocolStub.observeRequests = nil
        }
        
        // Determins if this kind of protocol can handle the request for the given request.
        override class func canInit(with request: URLRequest) -> Bool {
            URLProtocolStub.observeRequests?(request)
            return true
        }
        
        // Makes a certain request canonical (sinonym for unique) for the implemented protocol
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        // Starts protocol-specific loading of the request.
        override func startLoading() {
            if let error = URLProtocolStub.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            if let data = URLProtocolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = URLProtocolStub.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        // Stops protocol-specific loading of the request.
        override func stopLoading() {}
    }
}
