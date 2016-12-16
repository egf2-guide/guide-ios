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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let identifier = tableView.cellForRow(at: indexPath)?.reuseIdentifier, identifier == "LogoutCell" else { return }
        
        ProgressController.show()
        Graph.logout { (_, error) in
            ProgressController.hide()
            
            SimpleFileManager.shared.deleteAllFiles()
            self.tabBarController?.dismiss(animated: true, completion: nil)
        }
    }
}
