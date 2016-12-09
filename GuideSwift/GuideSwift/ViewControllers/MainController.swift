//
//  MainController.swift
//  GuideSwift
//
//  Created by LuzanovRoman on 09.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

import UIKit

class MainController: UIViewController {
    
    fileprivate var initController: InitController? {
        get {
            return self.navigationController as? InitController
        }
    }
    
    @IBAction func logout(_ sender: AnyObject) {
        Graph.logout { (_, error) in
            self.initController?.performSegue(withIdentifier: "ShowLoginScreen", sender: nil)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if !Graph.isAuthorized {
            self.initController?.viewControllers = []
        }
    }
}
