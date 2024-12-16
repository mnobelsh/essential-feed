//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by Muhammad Nobel Shidqi on 16/12/24.
//

import Foundation
import EssentialFeed

struct FeedLoadingViewModel {
    let isLoading: Bool
}

protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

struct FeedViewModel {
    let feed: [FeedImage]
}

protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

final class FeedPresenter {
    private let feedLoader: FeedLoader
    
    var feedView: FeedView?
    var loadingView: FeedLoadingView?
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    func loadFeed() {
        loadingView?.display(FeedLoadingViewModel(isLoading: true))
        
        feedLoader.load { [weak self] result in
            guard let self else { return }
            if let feed = try? result.get() {
                feedView?.display(FeedViewModel(feed: feed))
            }
            
            loadingView?.display(FeedLoadingViewModel(isLoading: false))
        }
    }
}
