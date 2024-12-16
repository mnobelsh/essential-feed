//
//  FeedViewModel.swift
//  EssentialFeed
//
//  Created by Muhammad Nobel Shidqi on 16/12/24.
//

import Foundation
import EssentialFeed

final class FeedViewModel {
    private let feedLoader: FeedLoader
    
    var onChange: ((FeedViewModel) -> Void)?
    var onFeedLoad: (([FeedImage]) -> Void)?
    
    private(set) var isLoading: Bool = false {
        didSet {
            onChange?(self)
        }
    }
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    func loadFeed() {
        isLoading = true
        feedLoader.load { [weak self] result in
            guard let self else { return }
            isLoading = false
            if let feed = try? result.get() {
                onFeedLoad?(feed)
            }
        }
    }
}
