//
//  FeedImageCell.swift
//  Prototype
//
//  Created by Muhammad Nobel Shidqi on 01/12/24.
//

import UIKit

final class FeedImageCell: UITableViewCell {

    @IBOutlet weak var locationContainer: UIStackView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var feedImageContainer: UIView!
    @IBOutlet weak var feedImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        feedImageContainer.isShimmering = true
        feedImageView.alpha = 0
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        feedImageContainer.isShimmering = true
        feedImageView.alpha = 0
    }
    
    func fadeIn(_ image: UIImage?) {
        feedImageView.image = image
        
        UIView.animate(
            withDuration: 0.3,
            delay: 0.3,
            options: .curveEaseIn,
            animations: {
                self.feedImageView.alpha = 1
            },
            completion: { completed in
                if completed {
                    self.feedImageContainer.isShimmering = false
                }
            })
    }

}
