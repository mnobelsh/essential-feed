//
//  FeedImageCell.swift
//  EssentialFeediOS
//
//  Created by Muhammad Nobel Shidqi on 03/12/24.
//

import UIKit

public final class FeedImageCell: UITableViewCell {
    
    public let locationContainer = UIView()
    public let locationLabel = UILabel()
    public let descriptionLabel = UILabel()
    public let feedImageContainer = UIView()
    public let feedImageView = UIImageView()
    private(set) public lazy var feedImageRetryButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        return button
    }()

    var onRetry: (() -> Void)?

    public override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @objc func retryButtonTapped() {
        onRetry?()
    }

}
