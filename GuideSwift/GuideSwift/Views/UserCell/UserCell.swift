//
//  UserCell.swift
//  GuideSwift
//
//  Created by LuzanovRoman on 21.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

import UIKit

@objc protocol UserCellDelegate {
    func didTapFollowButton(withUser user: EGFUser, andCell cell: UserCell)
}

class UserCell: UITableViewCell {
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    weak var delegate: UserCellDelegate?
    
    weak var user: EGFUser? = nil {
        didSet {
            userNameLabel.text = user?.name?.fullName()
            applyFollowState()
        }
    }
    
    fileprivate func applyFollowState() {
        followButton.setImage(#imageLiteral(resourceName: "follow"), for: .normal)
        followButton.isHidden = false
        
        guard let theUser = user else { return }
        
        switch Follows.shared.followState(forUser: theUser) {
        case .isMe:
            followButton.isHidden = true
            
        case .isFollow:
            followButton.setImage(#imageLiteral(resourceName: "follow_added"), for: .normal)
            
        case .isNotFollow:
            ()
            
        case .isUnknown:
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
                self.applyFollowState()
            }
        }
    }
    
    @IBAction func didTapFollowButton(_ sender: AnyObject) {
        if let theUser = user {
            delegate?.didTapFollowButton(withUser: theUser, andCell: self)
        }
    }
}

