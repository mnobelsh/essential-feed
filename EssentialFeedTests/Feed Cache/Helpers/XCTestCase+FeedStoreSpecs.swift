//
//  XCTestCase+FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Muhammad Nobel Shidqi on 23/11/24.
//

import XCTest
import EssentialFeed

extension FeedStoreSpecs where Self: XCTestCase {
    func expect(_ sut: FeedStore, toRetrieve expectedResult: FeedStore.RetrievalResult, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Waiting for retrieval completion.")
        
        sut.retrieve { receivedResult in
            switch (receivedResult, expectedResult) {
            case (.success(.none), .success(.none)),
                (.failure,.failure):
                break
                
            case let (.success(receivedCache), .success(expectedCache)):
                XCTAssertEqual(receivedCache?.feed, expectedCache?.feed, file: file, line: line)
                XCTAssertEqual(receivedCache?.timestamp, expectedCache?.timestamp, file: file, line: line)
                
            default:
                XCTFail("Expected to retrieve \(expectedResult), got \(receivedResult) instead.", file: file, line: line)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: FeedStore.RetrievalResult, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }
    
    @discardableResult
    func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: FeedStore) -> Error? {
        let exp = expectation(description: "Waiting for cache retrieval.")
        
        var receivedError: Error?
        sut.insert(cache.feed, timestamp: cache.timestamp) { result in
            switch result {
            case let .failure(error):
                receivedError = error
            default:
                break
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        
        return receivedError
    }
    
    @discardableResult
    func deleteCache(from sut: FeedStore) -> Error? {
        let exp = expectation(description: "Waiting for cache retrieval.")
        
        var receivedError: Error?
        sut.deleteCachedFeed { result in
            switch result {
            case let .failure(error):
                receivedError = error
            default:
                break
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        
        return receivedError
    }
}
