//
//  BaseDownloader.swift
//  GuideSwift
//
//  Created by LuzanovRoman on 22.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

import UIKit

class BaseDownloader <T: NSObject>: NSObject {
    
    var graphObjects = [T]()
    var totalCount = -1
    
    weak var tableView: UITableView?
    
    subscript(index: Int) -> T {
        get {
            return graphObjects[index]
        }
    }
    
    var last: T? {
        get {
            return graphObjects.last
        }
    }
    
    var count: Int {
        get {
            return graphObjects.count
        }
    }
    
    var isDownloaded: Bool {
        get {
            return graphObjects.count == totalCount
        }
    }
    
    func refreshList() {
        // Override this
    }
    
    func getNextPage() {
        // Override this
    }
}
