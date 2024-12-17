//
//  FeedRefreshViewController.swift
//  EssentialFeed
//
//  Created by Muhammad Nobel Shidqi on 12/12/24.
//

import UIKit

protocol FeedRefreshViewControllerDelegate: AnyObject {
    func didRequestFeedRefresh()
}

public final class FeedRefreshViewController: NSObject {
    public lazy var view: UIRefreshControl = loadView()
    
    private let delegate: FeedRefreshViewControllerDelegate
    
    init(delegate: FeedRefreshViewControllerDelegate) {
        self.delegate = delegate
    }
    
    @objc func refresh() {
        delegate.didRequestFeedRefresh()
    }
    
    func loadView() -> UIRefreshControl {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}

extension FeedRefreshViewController: FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel) {
        viewModel.isLoading ? self.view.beginRefreshing() : self.view.endRefreshing()
    }
}
