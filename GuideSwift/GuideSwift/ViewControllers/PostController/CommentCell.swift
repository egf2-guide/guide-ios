//
//  CommentCell.swift
//  GuideSwift
//
//  Created by LuzanovRoman on 19.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

import UIKit

protocol CommentCellDelegate: NSObjectProtocol {
    var authorizedUserId: String? { get }
    func delete(comment: EGFComment)
    func edit(comment: EGFComment)
}

class CommentCell: UITableViewCell {
    @IBOutlet weak var creatorNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    weak var delegate: CommentCellDelegate?

    static func height(forComment comment: EGFComment) -> CGFloat {
        var height: CGFloat = 51 // height of cell without text

        let font = UIFont.systemFont(ofSize: 15)
        let width = UIScreen.main.bounds.size.width - 32

        if let value = comment.text {
            let size = CGSize(width: width, height: CGFloat(FLT_MAX))
            let frame = value.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
            height += frame.size.height + 8
        }
        return height
    }

    weak var comment: EGFComment? {
        didSet {
            if let userId = delegate?.authorizedUserId, let creatorId = comment?.creator, userId == creatorId {
                deleteButton.isHidden = false
                editButton.isHidden = false
            } else {
                deleteButton.isHidden = true
                editButton.isHidden = true
            }
            creatorNameLabel.text = comment?.creatorObject?.name?.fullName()
            descriptionLabel.text = comment?.text
        }
    }

    @IBAction func deleteComment(_ sender: AnyObject) {
        guard let theDelegate = delegate, let theComment = comment else { return }
        theDelegate.delete(comment: theComment)
    }

    @IBAction func editComment(_ sender: AnyObject) {
        guard let theDelegate = delegate, let theComment = comment else { return }
        theDelegate.edit(comment: theComment)
    }
}
