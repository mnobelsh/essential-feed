//
//  FeedRefreshViewController.swift
//  EssentialFeed
//
//  Created by Muhammad Nobel Shidqi on 12/12/24.
//

import UIKit

public final class FeedRefreshViewController: NSObject {
    public lazy var view: UIRefreshControl = loadView()
    
    private let presenter: FeedPresenter
    
    init(presenter: FeedPresenter) {
        self.presenter = presenter
    }
    
    @objc func refresh() {
        presenter.loadFeed()
    }
    
    func loadView() -> UIRefreshControl {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}

extension FeedRefreshViewController: FeedLoadingView {
    func display(isLoading: Bool) {
        isLoading ? self.view.beginRefreshing() : self.view.endRefreshing()
    }
}
