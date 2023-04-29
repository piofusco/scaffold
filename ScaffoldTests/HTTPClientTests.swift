//
//  ScaffoldTests.swift
//  ScaffoldTests
//
//  Created by Michael Pace on 4/23/23.
//

import XCTest

@testable import Scaffold

final class HTTPClientTests: XCTestCase {
    var subject: DefaultHTTPClient!

    var mockURLSession: MockURLSession!
    var mockJSONDecoder: MockJSONDecoder<GiphySearchResultImage>!

    override func setUp() {
        super.setUp()

        mockURLSession = MockURLSession()
        mockJSONDecoder = MockJSONDecoder()

        subject = DefaultHTTPClient(
            urlSession: mockURLSession,
            decoder: mockJSONDecoder
        )
    }

    func test_get_200_returnsDecodable_success() async throws {
        mockURLSession.nextResults = [("".data(using: .utf16)!, url200Response)]
        mockJSONDecoder.nextDecodable = GiphySearchResultImage(url: URL(string: "www.whatever.com")!)

        let result: Result<GiphySearchResultImage, Error> = await subject.request(
            url: GiphyURL.search,
            method: .get,
            [:]
        )

        switch result {
            case .success(let decoded): XCTAssertNotNil(decoded)
            case .failure(_): XCTFail("Should not fail")
        }
        let lastURLRequest = mockURLSession.lastURLRequests[0]
        XCTAssertEqual(lastURLRequest.url?.path, "/v1/gifs/search")
        XCTAssertEqual(lastURLRequest.httpMethod, "GET")
        XCTAssertEqual(mockJSONDecoder.decodeInvocations, 1)
    }

    func test_get_200_decodingFails_failure() async throws {
        mockURLSession.nextResults = [(invalidJSON, url200Response)]
        var lastError: Error?

        let result: Result<GiphySearchResultImage, Error> = await subject.request(
            url: GiphyURL.search,
            method: .get,
            [:]
        )

        switch result {
            case .success(_): XCTFail("Should not succeed")
            case .failure(let error): lastError = error
        }
        XCTAssertNotNil(lastError)
        let lastURLRequest = mockURLSession.lastURLRequests[0]
        XCTAssertEqual(lastURLRequest.url?.path, "/v1/gifs/search")
        XCTAssertEqual(lastURLRequest.httpMethod, "GET")
        XCTAssertEqual(mockJSONDecoder.decodeInvocations, 1)
    }

    func test_get_400_failure() async throws {
        mockURLSession.nextResults = [("some data".data(using: .utf16)!, url400Response)]
        var lastError: Error?

        let result: Result<GiphySearchResultImage, Error> = await subject.request(
            url: GiphyURL.search,
            method: .get,
            [:]
        )

        switch result {
            case .success(_): XCTFail("Should not succeed")
            case .failure(let error): lastError = error
        }
        XCTAssertNotNil(lastError)
        let lastURLRequest = mockURLSession.lastURLRequests[0]
        XCTAssertEqual(lastURLRequest.url?.path, "/v1/gifs/search")
        XCTAssertEqual(lastURLRequest.httpMethod, "GET")
        XCTAssertEqual(mockJSONDecoder.decodeInvocations, 0)
    }

    func test_get_500_failure() async throws {
        mockURLSession.nextResults = [("some data".data(using: .utf16)!, url500Response)]
        var lastError: Error?

        let result: Result<GiphySearchResultImage, Error> = await subject.request(
            url: GiphyURL.search,
            method: .get,
            [:]
        )

        switch result {
            case .success(_): XCTFail("Should not succeed")
            case .failure(let error): lastError = error
        }
        XCTAssertNotNil(lastError)
        let lastURLRequest = mockURLSession.lastURLRequests[0]
        XCTAssertEqual(lastURLRequest.url?.path, "/v1/gifs/search")
        XCTAssertEqual(lastURLRequest.httpMethod, "GET")
        XCTAssertEqual(mockJSONDecoder.decodeInvocations, 0)
    }
}

fileprivate let invalidJSON = "lol good lucky{".data(using: .utf8)!
fileprivate let url200Response: URLResponse = HTTPURLResponse(
    url: URL(string: "www.not.matter")!,
    statusCode: 200,
    httpVersion: nil,
    headerFields: [:]
)!

fileprivate let url400Response: URLResponse = HTTPURLResponse(
    url: URL(string: "www.not.matter")!,
    statusCode: 400,
    httpVersion: nil,
    headerFields: [:]
)!

fileprivate let url500Response: URLResponse = HTTPURLResponse(
    url: URL(string: "www.not.matter")!,
    statusCode: 500,
    httpVersion: nil,
    headerFields: [:]
)!
