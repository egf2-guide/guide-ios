//
//  OffensivePostButton.swift
//  GuideSwift
//
//  Created by LuzanovRoman on 29.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

import UIKit

class OffensivePostButton: UIButton {

    weak var post: EGFPost? {
        didSet {
            checkOffensiveState()
        }
    }

    func checkOffensiveState() {
        tintColor = UIColor.white

        guard let thePost = post else { return }

        switch OffensivePosts.shared.offensiveState(forPost: thePost) {
        case .isOffensive:
            tintColor = UIColor.yellow

        case .isNotOffensive:
            ()

        case .isUnknown:
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(2)) { [weak self] in
                self?.checkOffensiveState()
            }
        }
    }
}
