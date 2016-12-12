//
//  MoreController.swift
//  GuideSwift
//
//  Created by LuzanovRoman on 12.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

import UIKit

class MoreController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 0.1))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        parent?.title = "More"
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let initController = self.navigationController as? InitController else { return }
        guard let identifier = tableView.cellForRow(at: indexPath)?.reuseIdentifier, identifier == "LogoutCell" else { return }
            
        Graph.logout { (_, error) in
            initController.performSegue(withIdentifier: "ShowLoginScreen", sender: nil)
        }
    }
}
