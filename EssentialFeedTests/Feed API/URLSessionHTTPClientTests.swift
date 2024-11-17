//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Muhammad Nobel Shidqi on 17/11/24.
//

import XCTest
import EssentialFeed

protocol HTTPSession {
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, (any Error)?) -> Void) -> HTTPSessionTask
}

protocol HTTPSessionTask  {
    func resume()
}

final class URLSessionHTTPClient {
    private let session: HTTPSession
    
    init(session: HTTPSession) {
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { _, _, error in
            if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
}

final class URLSessionHTTPClientTests: XCTestCase {
    
    func test_getFromURL_resumesDataTaskWithURL() {
        let url = URL(string: "https://any-url.com")!
        let session = HTTPSessionSpy()
        let task = URLSessionDataTaskSpy()
        let sut = URLSessionHTTPClient(session: session)
        
        session.stub(url: url, task: task)
        
        sut.get(from: url) { _ in }
        
        XCTAssertEqual(task.resumeCallCount, 1)
    }
    
    func test_getFromURL_failsOnRequestError() {
        let url = URL(string: "https://any-url.com")!
        let session = HTTPSessionSpy()
        let error = NSError(domain: "Any Error", code: 0)
        let sut = URLSessionHTTPClient(session: session)
        
        session.stub(url: url, error: error)
        
        let exp = expectation(description: "Wait for completion.")
        sut.get(from: url) { result in
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError, error)
            default:
                XCTFail("Expected failure with error \(error), got \(result) instead.")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }

}

// MARK: - Helpers
private extension URLSessionHTTPClientTests {
    
    class HTTPSessionSpy: HTTPSession {
        private var stubs = [URL: Stub]()
        
        private struct Stub {
            let task: HTTPSessionTask
            let error: Error?
        }
        
        func stub(url: URL, task: HTTPSessionTask = FakeURLSessionDataTask(), error: Error? = nil) {
            stubs[url] = Stub(task: task, error: error)
        }
        
        func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, (any Error)?) -> Void) -> HTTPSessionTask {
            guard let stub = stubs[url] else {
                fatalError("Could not find stub for the given url \(url).")
            }
            completionHandler(nil, nil, stub.error)
            return stub.task
        }
    }
    
    class FakeURLSessionDataTask: HTTPSessionTask {
        func resume() {}
    }
    
    class URLSessionDataTaskSpy: HTTPSessionTask {
        var resumeCallCount = 0
        
        func resume() {
            resumeCallCount += 1
        }
    }
}
