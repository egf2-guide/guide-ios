//
//  FeedPostCell.swift
//  GuideSwift
//
//  Created by LuzanovRoman on 13.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

import UIKit

class FeedPostCell: UITableViewCell {
    @IBOutlet weak var creatorNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    var post: EGFPost?
    
    func set(postImage: UIImage?, animated: Bool) {
        postImageView.image = postImage
        
        guard let _ = postImage else {
            postImageView.alpha = 0
            activityIndicatorView.startAnimating()
            return
        }
        activityIndicatorView.stopAnimating()
        
        if animated {
            UIView.animate(withDuration: 0.3, animations: {
                self.postImageView.alpha = 1
            }) { (finished) in
                self.postImageView.alpha = 1
            }
        }
        else {
            postImageView.alpha = 1
        }
    }
    
    static func height(forPost post: EGFPost) -> CGFloat {
        var height: CGFloat = 46 // height of cell without image and description
        
        let font = UIFont.systemFont(ofSize: 15)
        let width = UIScreen.main.bounds.size.width - 32
        
        if let value = post.desc {
            let size = CGSize(width: width, height: CGFloat(FLT_MAX))
            let frame = value.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
            height += frame.size.height + 8
        }
        if let value = post.imageObject?.dimensions {
            let imageRatio = CGFloat(value.width) / CGFloat(value.height)
            let imageWidth = min(width, CGFloat(value.width) / UIScreen.main.scale)
            let imageHeight = imageWidth / imageRatio
            height += imageHeight + 8
        }
        return height
    }
}
