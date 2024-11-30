//
//  FeedViewController.swift
//  Prototype
//
//  Created by Muhammad Nobel Shidqi on 01/12/24.
//

import UIKit

struct FeedImageViewModel {
    var location: String? = nil
    var description: String? = nil
    var imageName: String
}

final class FeedViewController: UITableViewController {
    private let feed = FeedImageViewModel.prototypeFeed

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feed.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FeedImageCell", for: indexPath) as? FeedImageCell else {
            return UITableViewCell()
        }
        let model = feed[indexPath.row]
        cell.configure(with: model)
        return cell
    }

}

extension FeedImageCell {
    func configure(with model: FeedImageViewModel) {
        feedImageView.image = UIImage(named: model.imageName)
        
        locationLabel.text = model.location
        locationContainer.isHidden = model.location == nil
        
        descriptionLabel.text = model.description
        descriptionLabel.isHidden = model.description == nil
    }
}
