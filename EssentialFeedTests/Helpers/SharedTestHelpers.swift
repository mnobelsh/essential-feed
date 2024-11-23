//
//  SharedTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Muhammad Nobel Shidqi on 23/11/24.
//

import Foundation

func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
}

func anyURL() -> URL {
    return URL(string: "https://any-url.com")!
}
