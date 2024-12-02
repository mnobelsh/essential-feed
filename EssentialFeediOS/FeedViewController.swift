//
//  FeedViewController.swift
//  EssentialFeed
//
//  Created by Muhammad Nobel Shidqi on 01/12/24.
//

import UIKit
import EssentialFeed

public final class FeedViewController: UITableViewController {
    private var loader: FeedLoader?
    private var tableModel = [FeedImage]()
    
    private var onViewIsAppearing: ((_ vc: FeedViewController) -> Void)?
    
    public convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        onViewIsAppearing = { vc in
            vc.refresh()
            vc.onViewIsAppearing = nil
        }
    }
    
    public override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        onViewIsAppearing?(self)
    }
    
    @objc private func refresh() {
        refreshControl?.beginRefreshing()
        loader?.load { [weak self] result in
            guard let self else { return }
            
            self.tableModel = (try? result.get()) ?? []
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }
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
        return cell
    }
}
