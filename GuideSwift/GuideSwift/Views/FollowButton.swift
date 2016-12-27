//
//  FollowButton.swift
//  GuideSwift
//
//  Created by LuzanovRoman on 27.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

import UIKit

class FollowButton: UIButton {
    
    weak var user: EGFUser? {
        didSet {
            checkFollowState()
        }
    }
    
    func checkFollowState() {
        setImage(#imageLiteral(resourceName: "follow"), for: .normal)
        isHidden = false
        
        guard let theUser = user else { return }
        
        switch Follows.shared.followState(forUser: theUser) {
        case .isMe:
            isHidden = true
            
        case .isFollow:
            setImage(#imageLiteral(resourceName: "follow_added"), for: .normal)
            
        case .isNotFollow:
            ()
            
        case .isUnknown:
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) { [weak self] in
                self?.checkFollowState()
            }
        }
    }
}
