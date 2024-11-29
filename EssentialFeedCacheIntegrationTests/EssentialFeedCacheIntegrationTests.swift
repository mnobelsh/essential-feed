//
//  EssentialFeedCacheIntegrationTests.swift
//  EssentialFeedCacheIntegrationTests
//
//  Created by Muhammad Nobel Shidqi on 30/11/24.
//

import XCTest
import EssentialFeed

final class EssentialFeedCacheIntegrationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        
        undoStoreSideEffects()
    }

    func test_load_deliversNoItemsOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toLoad: [])
    }
    
    func test_load_deliversItemsSavedOnASeparateInstance() {
        let sutToPerformSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let feed = uniqueImageFeed().models
        
        let saveExp = expectation(description: "Waiting for save completion.")
        sutToPerformSave.save(feed) { result in
            XCTAssertNil(result)
            saveExp.fulfill()
        }
        wait(for: [saveExp], timeout: 1)
        
        expect(sutToPerformLoad, toLoad: feed)
    }

}

// MARK: - Helpers
private extension EssentialFeedCacheIntegrationTests {
    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> LocalFeedLoader {
        let bundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = testSpecificStoreURL()
        let store = try! CoreDataFeedStore(storeURL: storeURL, bundle: bundle)
        let sut = LocalFeedLoader(store: store, currentDate: Date.init)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    func expect(_ sut: LocalFeedLoader, toLoad feed: [FeedImage], file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Waiting for load completion.")
        sut.load { result in
            switch result {
            case let .success(receivedFeed):
                XCTAssertEqual(receivedFeed, feed, file: file, line: line)
            default:
                XCTFail("Expected to receive empty feed, got \(result) instead.", file: file, line: line)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }
    
    func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }
    
    func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    
    func testSpecificStoreURL() -> URL {
        return cachesDirectoryURL().appendingPathComponent("\(type(of: self)).store")
    }
    
    func cachesDirectoryURL() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}
