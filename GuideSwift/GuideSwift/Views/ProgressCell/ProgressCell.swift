//
//  ProgressCell.swift
//  GuideSwift
//
//  Created by LuzanovRoman on 21.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

import UIKit

class ProgressCell: UITableViewCell {
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!

    var indicatorIsHidden: Bool = true {
        didSet {
            activityIndicatorView.isHidden = indicatorIsHidden
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
