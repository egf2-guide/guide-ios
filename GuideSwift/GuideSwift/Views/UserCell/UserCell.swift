//
//  UserCell.swift
//  GuideSwift
//
//  Created by LuzanovRoman on 21.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

import UIKit

@objc protocol UserCellDelegate {
    func didTapFollowButton(withUser user: EGFUser)
}

class UserCell: UITableViewCell {
    @IBOutlet weak var userNameLabel: UILabel!
    weak var delegate: UserCellDelegate?
    
    weak var user: EGFUser? = nil {
        didSet {
            userNameLabel.text = user?.name?.fullName()
        }
    }
    
    @IBAction func didTapFollowButton(_ sender: AnyObject) {
        if let theUser = user {
            delegate?.didTapFollowButton(withUser: theUser)
        }
    }
}

