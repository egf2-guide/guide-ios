//
//  MainTabBarController.swift
//  GuideSwift
//
//  Created by LuzanovRoman on 09.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidDisappear(_ animated: Bool) {
        guard let initController = self.navigationController as? InitController else { return }
        
        if !Graph.isAuthorized {
            initController.viewControllers = []
        }
    }
}
