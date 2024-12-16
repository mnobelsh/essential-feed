//
//  FeedViewModel.swift
//  EssentialFeed
//
//  Created by Muhammad Nobel Shidqi on 16/12/24.
//

import Foundation
import EssentialFeed

typealias Observer<T> = (T) -> Void

final class FeedViewModel {
    private let feedLoader: FeedLoader
    
    var onLoadingStateChange: Observer<Bool>?
    var onFeedLoad: Observer<[FeedImage]>?
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    func loadFeed() {
        onLoadingStateChange?(true)
        
        feedLoader.load { [weak self] result in
            guard let self else { return }
            if let feed = try? result.get() {
                onFeedLoad?(feed)
            }
            
            onLoadingStateChange?(false)
        }
    }
}
