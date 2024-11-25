//
//  CoreDataFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Muhammad Nobel Shidqi on 23/11/24.
//

import XCTest
import EssentialFeed


final class CoreDataFeedStoreTests: XCTestCase, FeedStoreSpecs {
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toRetrieve: .empty)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        
    }
    
    func test_retrieveAfterInsertingFromEmptyCache_deliversInsertedValues() {
        
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        
    }
    
    func test_insert_overridesPreviouslyInsertedCacheValues() {
        
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
        
    }
    
    func test_storeSideEffects_runSerially() {
        
    }

}

private extension CoreDataFeedStoreTests {
    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> FeedStore {
        let bundle = Bundle(for: CoreDataFeedStore.self)
        let url = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataFeedStore(storeURL: url, bundle: bundle)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
}
