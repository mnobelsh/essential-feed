//
//  XCTestCase+MemoryLeaksTracking.swift
//  EssentialFeedTests
//
//  Created by Muhammad Nobel Shidqi on 17/11/24.
//

import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(
        _ instance: AnyObject,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leaks.", file: file, line: line)
        }
    }
}
