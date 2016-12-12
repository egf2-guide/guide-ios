//
//  InitController.swift
//  GuideSwift
//
//  Created by LuzanovRoman on 09.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

import UIKit

class InitController: UIViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if Graph.isAuthorized {
            performSegue(withIdentifier: "ShowTabBar", sender: nil)
        }
        else {
            performSegue(withIdentifier: "ShowLoginScreen", sender: nil)
        }
    }
}
