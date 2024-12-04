//
//  FeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Muhammad Nobel Shidqi on 04/12/24.
//

import Foundation

public protocol FeedImageDataLoaderTask {
    func cancel()
}

public protocol FeedImageDataLoader {
    typealias Result = Swift.Result<Data, Error>
    
    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> FeedImageDataLoaderTask
}
