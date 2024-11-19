//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Muhammad Nobel Shidqi on 20/11/24.
//

import XCTest
import EssentialFeed

class FeedStore {
    var deleteCachedFeedCallCount = 0
    
    func deleteCachedFeed() {
        deleteCachedFeedCallCount += 1
    }
}

final class LocalFeedLoader {
    private let store: FeedStore
    
    init(store: FeedStore) {
        self.store = store
    }
    
    func save(_ feed: [FeedItem]) {
        store.deleteCachedFeed()
    }
}

final class CacheFeedUseCaseTests: XCTestCase {

    func test_init_doesNotDeletesCacheUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }
    
    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        
        sut.save(items)
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 1)
    }

}

// MARK: - Helpers
private extension CacheFeedUseCaseTests {
    
    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        return (sut, store)
    }
    
    func uniqueItem() -> FeedItem {
        return FeedItem(id: UUID(), description: "description", location: "location", imageURL: anyURL())
    }
    
    func anyURL() -> URL {
        return URL(string: "https://any-url.com")!
    }
    
}
