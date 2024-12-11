//
//  FeedViewController.swift
//  EssentialFeed
//
//  Created by Muhammad Nobel Shidqi on 01/12/24.
//

import UIKit
import EssentialFeed

public final class FeedViewController: UITableViewController {
    public var refreshController: FeedRefreshViewController?
    private var feedLoader: FeedLoader?
    private var imageLoader: FeedImageDataLoader?
    private var tableModel = [FeedImage]() {
        didSet {
            tableView.reloadData()
        }
    }
    private var dataLoaderTasks = [IndexPath: FeedImageDataLoaderTask]()
    
    private var onViewIsAppearing: ((_ vc: FeedViewController) -> Void)?
    
    public convenience init(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) {
        self.init()
        self.feedLoader = feedLoader
        self.imageLoader = imageLoader
        self.refreshController = FeedRefreshViewController(feedLoader: feedLoader)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.prefetchDataSource = self
        
        refreshControl = refreshController?.view
        refreshController?.onRefresh = { [weak self] feed in
            guard let self else { return }
            self.tableModel = feed
        }
        
        onViewIsAppearing = { vc in
            vc.refreshController?.refresh()
            vc.onViewIsAppearing = nil
        }
    }
    
    public override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        onViewIsAppearing?(self)
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel = tableModel[indexPath.row]
        let cell = FeedImageCell()
        cell.locationContainer.isHidden = cellModel.location == nil
        cell.locationLabel.text = cellModel.location
        cell.descriptionLabel.text = cellModel.description
        cell.feedImageView.image = nil
        cell.feedImageRetryButton.isHidden = true
        cell.feedImageContainer.isShimmering = true
        
        let loadImage = { [weak self, weak cell] in
            guard let self else { return }
            dataLoaderTasks[indexPath] = imageLoader?.loadImageData(from: cellModel.url) { [weak cell] result in
                let data = try? result.get()
                let image = data.map(UIImage.init) ?? nil
                cell?.feedImageView.image = image
                cell?.feedImageRetryButton.isHidden = image != nil
                cell?.feedImageContainer.isShimmering = false
            }
        }
        
        cell.onRetry = loadImage
        loadImage()

        return cell
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelImageLoad(at: indexPath)
    }
    
    private func cancelImageLoad(at indexPath: IndexPath) {
        dataLoaderTasks[indexPath]?.cancel()
        dataLoaderTasks[indexPath] = nil
    }
}

extension FeedViewController: UITableViewDataSourcePrefetching {
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach {
            let cellModel = tableModel[$0.row]
            dataLoaderTasks[$0] = imageLoader?.loadImageData(from: cellModel.url) { _ in }
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelImageLoad)
    }
}
