//
//  OffensivePostCell.swift
//  GuideSwift
//
//  Created by LuzanovRoman on 09.01.17.
//  Copyright © 2017 eigengraph. All rights reserved.
//

import UIKit

protocol OffensivePostCellDelegate: NSObjectProtocol {
    func delete(post: EGFPost)
    func confirmAsOffensive(post: EGFPost)
}

class OffensivePostCell: UITableViewCell {
    @IBOutlet weak var creatorNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var postImageView: FileImageView!
    weak var delegate: OffensivePostCellDelegate?
    
    weak var post: EGFPost? {
        didSet {
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
    
    @IBAction func confirmAsOffensivePost(_ sender: AnyObject) {
        guard let theDelegate = delegate, let thePost = post else { return }
        theDelegate.confirmAsOffensive(post: thePost)
    }
}
