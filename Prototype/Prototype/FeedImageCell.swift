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
    @IBOutlet weak var feedImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
