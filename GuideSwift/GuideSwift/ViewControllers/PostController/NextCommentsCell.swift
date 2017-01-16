//
//  NextCommentsCell.swift
//  GuideSwift
//
//  Created by LuzanovRoman on 19.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

import UIKit

protocol NextCommentsCellDelegate: NSObjectProtocol {
    func showNext()
}

class NextCommentsCell: UITableViewCell {
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    weak var delegate: NextCommentsCellDelegate?

    var indicatorIsAnimated: Bool = false {
        didSet {
            if indicatorIsAnimated {
                activityIndicatorView.startAnimating()
            } else {
                activityIndicatorView.stopAnimating()
            }
        }
    }

    @IBAction func showNext(_ sender: AnyObject) {
        delegate?.showNext()
        indicatorIsAnimated = true
    }
}
