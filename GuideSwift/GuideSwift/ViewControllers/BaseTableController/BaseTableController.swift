//
//  BaseTableController.swift
//  GuideSwift
//
//  Created by LuzanovRoman on 13.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

import UIKit

class BaseTableController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl?.backgroundColor = UIColor.white
        refreshControl?.tintColor = UIColor.hexColor(0x5E66B1)
    }
}
