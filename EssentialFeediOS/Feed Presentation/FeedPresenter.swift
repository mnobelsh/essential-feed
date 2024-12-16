//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by Muhammad Nobel Shidqi on 16/12/24.
//

import Foundation
import EssentialFeed

protocol FeedLoadingView: AnyObject {
    func display(isLoading: Bool)
}

protocol FeedView {
    func display(feed: [FeedImage])
}

final class FeedPresenter {
    private let feedLoader: FeedLoader
    
    var feedView: FeedView?
    weak var loadingView: FeedLoadingView?
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    func loadFeed() {
        loadingView?.display(isLoading: true)
        
        feedLoader.load { [weak self] result in
            guard let self else { return }
            if let feed = try? result.get() {
                feedView?.display(feed: feed)
            }
            
            loadingView?.display(isLoading: false)
        }
    }
}
