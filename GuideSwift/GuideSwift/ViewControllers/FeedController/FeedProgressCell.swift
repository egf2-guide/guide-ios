//
//  FeedProgressCell.swift
//  GuideSwift
//
//  Created by LuzanovRoman on 14.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

import UIKit

class FeedProgressCell: UITableViewCell {
    @IBOutlet weak var cellHeight: NSLayoutConstraint!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    var indicatorIsHidden: Bool = true {
        didSet {
            activityIndicatorView.isHidden = indicatorIsHidden
            cellHeight.constant = indicatorIsHidden ? 1 : 40
        }
    }
    
    override public var isSelected: Bool {
        get {
            return super.isSelected
        }
        set {
            super.isSelected = newValue
            activityIndicatorView.startAnimating()
        }
    }
}
