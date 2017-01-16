//
//  SeparatorView.swift
//  GuideSwift
//
//  Created by LuzanovRoman on 13.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

import UIKit

class SeparatorView: UIView {

    override func awakeFromNib() {
        super.awakeFromNib()

        for layoutConstraint in self.constraints {
            if layoutConstraint.firstAttribute == .height {
                layoutConstraint.constant = 0.5
                break
            }
        }
    }
}
