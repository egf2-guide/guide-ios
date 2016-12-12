//
//  InitController.swift
//  GuideSwift
//
//  Created by LuzanovRoman on 09.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

import UIKit

class InitController: UINavigationController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if Graph.isAuthorized && viewControllers.isEmpty {
            guard let mainController = storyboard?.instantiateViewController(withIdentifier: "MainTabBar") else { return }
            viewControllers = [mainController]
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !Graph.isAuthorized {
            performSegue(withIdentifier: "ShowLoginScreen", sender: nil)
        }
    }
}
