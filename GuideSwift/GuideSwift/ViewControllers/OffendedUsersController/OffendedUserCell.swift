//
//  OffendedUserCell.swift
//  GuideSwift
//
//  Created by LuzanovRoman on 09.01.17.
//  Copyright © 2017 eigengraph. All rights reserved.
//

import UIKit

class OffendedUserCell: UITableViewCell {
    @IBOutlet weak var userNameLabel: UILabel!

    weak var offendedUser: EGFUser? = nil {
        didSet {
            userNameLabel.text = offendedUser?.name?.fullName()
        }
    }
}
