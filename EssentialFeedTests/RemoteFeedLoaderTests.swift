//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Muhammad Nobel Shidqi on 16/11/24.
//

import XCTest
import EssentialFeed

final class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestsDataFromURL() {
        let (sut, client) = makeSUT()

        XCTAssertTrue(client.requestedURLs.isEmpty)
    }

    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)

        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)

        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        var capturedError: [RemoteFeedLoader.Error] = []
        sut.load { error in
            capturedError.append(error)
        }
        
        let clientError = NSError(domain: "Client Error", code: 0)
        client.complete(with: clientError)
        
        XCTAssertEqual(capturedError, [.connectivity])
    }
    
}

private extension RemoteFeedLoaderTests {
    
    func makeSUT(url: URL = URL(string: "https://any-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    class HTTPClientSpy: HTTPClient {
        private var messages: [(url: URL, completion: (Error) -> Void)] = []
        var requestedURLs: [URL] {
            messages.map(\.url)
        }
        
        func get(from url: URL, completion: @escaping (Error) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(error)
        }
    }
    
}
