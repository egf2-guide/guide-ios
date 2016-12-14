//
//  FeedPostCell.swift
//  GuideSwift
//
//  Created by LuzanovRoman on 13.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

import UIKit

class FeedPostCell: UITableViewCell {
    @IBOutlet weak var postImageHeight: NSLayoutConstraint!
    @IBOutlet weak var creatorNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    
    var post: EGFPost?
    var postImage: UIImage? {
        didSet {
            if let image = postImage {
                let width = UIScreen.main.bounds.size.width - 32
                let imageRatio = image.size.width / image.size.height
                let imageWidth = min(width, image.size.width / UIScreen.main.scale)
                postImageHeight.constant = imageWidth / imageRatio
            }
            else {
                postImageHeight.constant = 0
            }
            postImageView.image = postImage
        }
    }
}
