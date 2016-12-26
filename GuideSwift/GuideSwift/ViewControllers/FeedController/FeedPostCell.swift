//
//  FeedPostCell.swift
//  GuideSwift
//
//  Created by LuzanovRoman on 13.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

import UIKit

protocol FeedPostCellDelegate: NSObjectProtocol {
    var authorizedUserId: String? { get }
    func delete(post: EGFPost)
}

class FeedPostCell: UITableViewCell {
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var creatorNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var postImageView: FileImageView!
    weak var delegate: FeedPostCellDelegate?
    
    weak var post: EGFPost? {
        didSet {
            if let userId = delegate?.authorizedUserId, let creatorId = post?.creator, userId == creatorId {
                deleteButton.isHidden = false
            }
            else {
                deleteButton.isHidden = true
            }
            creatorNameLabel.text = post?.creatorObject?.name?.fullName()
            descriptionLabel.text = post?.desc
            postImageView.file = post?.imageObject
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
    
    @IBAction func deletePost(_ sender: AnyObject) {
        guard let theDelegate = delegate, let thePost = post else { return }
        theDelegate.delete(post: thePost)
    }
}
