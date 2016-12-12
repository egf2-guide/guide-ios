//
//  MoreCell.swift
//  GuideSwift
//
//  Created by LuzanovRoman on 12.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

import UIKit

class MoreCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let background = UIView()
        background.backgroundColor = UIColor.hexColor(0x5E66B1).withAlphaComponent(0.25)
        selectedBackgroundView = background
    }
}
