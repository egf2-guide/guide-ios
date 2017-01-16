//
//  MainTabBarController.swift
//  GuideSwift
//
//  Created by LuzanovRoman on 09.01.17.
//  Copyright © 2017 eigengraph. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        Graph.userObject { (object, _) in
            guard let user = object as? EGFUser, let userId = user.id else { return }

            Graph.objects(forSource: userId, edge: "roles") { (objects, _, _) in
                guard let roles = objects else { return }

                for role in roles {
                    if role is EGFAdminRole {
                        self.showOffensivePostTab()
                        break
                    }
                }
            }
        }
    }

    func showOffensivePostTab() {
        guard let controller = storyboard?.instantiateViewController(withIdentifier: "OffensivePosts"), var controllers = viewControllers else { return }
        controller.tabBarItem = UITabBarItem(title: "Offensive Posts", image: #imageLiteral(resourceName: "tab_offensive_posts"), tag: 0)
        controllers.insert(controller, at: 1)
        viewControllers = controllers
    }
}
