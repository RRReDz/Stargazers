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
        
        makeSUT().get(from: url) { _ in }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_get_deliversFailureOnRequestError() {
        let error = anyNSError()
        let receivedError = resultErrorFor(data: nil, response: nil, error: error)
        
        let receivedNSError = receivedError as NSError?
        XCTAssertEqual(receivedNSError?.domain, error.domain)
        XCTAssertEqual(receivedNSError?.code, error.code)
    }
    
    func test_get_deliversSuccessOnRequestDeliveredWithHTTPURLResponseAndData() {
        let data = anyData()
        let httpResponse = anyHTTPURLResponse()
        
        let retrievedValues = resultValuesFor(
            data: data,
            response: httpResponse,
            error: nil)
        
        XCTAssertEqual(retrievedValues?.data, data)
        XCTAssertEqual(retrievedValues?.response.url, httpResponse.url)
        XCTAssertEqual(retrievedValues?.response.statusCode, httpResponse.statusCode)
    }
    
    func test_get_deliversSuccessOnRequestDeliveredWithHTTPURLResponseAndNilData() {
        let httpResponse = anyHTTPURLResponse()
        
        let retrievedValues = resultValuesFor(
            data: nil,
            response: httpResponse,
            error: nil)
        
        let emptyData = Data()
        XCTAssertEqual(retrievedValues?.data, emptyData, "Expected receivedData to be empty data")
        XCTAssertEqual(retrievedValues?.response.url, httpResponse.url)
        XCTAssertEqual(retrievedValues?.response.statusCode, httpResponse.statusCode)
    }
    
    func test_get_deliversFailureForAllInvalidRepresentableStates() {
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyURLResponse(), error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyURLResponse(), error: nil))
    }
    
    // MARK: - Utils
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> HTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func resultErrorFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        URLProtocolStub.stub(data: data, response: response, error: error)
        let result = resultFor(data: data, response: response, error: error)
        switch result {
        case let .failure(error):
            return error
        default:
            XCTFail("Expected failure, got \(String(describing: result)) instead", file: file, line: line)
            return nil
        }
    }
    
    private func resultValuesFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> (data: Data, response: HTTPURLResponse)? {
        let result = resultFor(data: data, response: response, error: error)
        switch result {
        case let .success(values):
            return values
        default:
            XCTFail("Expected success, got \(String(describing: result)) instead", file: file, line: line)
            return nil
        }
    }
    
    private func resultFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> HTTPClient.Result? {
        URLProtocolStub.stub(data: data, response: response, error: error)
        let exp = expectation(description: "Wait for get completion")
        
        var capturedResult: HTTPClient.Result?
        makeSUT(file: file, line: line).get(from: anyURL()) { result in
            capturedResult = result
            exp.fulfill()
        }

        wait(for: [exp], timeout: 2.0)
        
        return capturedResult
    }
    
    private func anyData() -> Data {
        return "any data".data(using: .utf8)!
    }
    
    private func anyURLResponse() -> URLResponse {
        return URLResponse(
            url: anyURL(),
            mimeType: nil,
            expectedContentLength: 10,
            textEncodingName: nil)
    }
    
    private func anyHTTPURLResponse() -> HTTPURLResponse {
        return HTTPURLResponse(
            url: anyURL(),
            statusCode: 300,
            httpVersion: nil,
            headerFields: nil)!
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
            stub = nil
            observeRequests = nil
        }
        
        // Determins if this kind of protocol can handle the request for the given request.
        override class func canInit(with request: URLRequest) -> Bool {
            return true
        }
        
        // Makes a certain request canonical (sinonym for unique) for the implemented protocol
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        // Starts protocol-specific loading of the request.
        override func startLoading() {
            if let observeRequests = URLProtocolStub.observeRequests {
                client?.urlProtocolDidFinishLoading(self)
                return observeRequests(request)
            }
            
            if let data = URLProtocolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = URLProtocolStub.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = URLProtocolStub.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        // Stops protocol-specific loading of the request.
        override func stopLoading() {}
    }
}
