//
//  ReversedTableViewHandler.swift
//  GuideSwift
//
//  Created by LuzanovRoman on 19.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

import UIKit

class ReversedTableViewHandler<T>: TableViewHandler<T> {
    
    override var last: T? {
        get {
            return graphObjects.first
        }
    }
    
    override func add(objects: [T]?, totalCount count: Int) {
        guard let theObjects = objects else { return }
        
        var indexPaths = [IndexPath]()
        
        for i in 0..<theObjects.count {
            indexPaths.append(IndexPath(row: i, section: 1))
        }
        totalCount = count

        for object in theObjects {
            graphObjects.insert(object, at: 0)
        }
        tableView?.beginUpdates()
        tableView?.insertRows(at: indexPaths, with: .none)
        tableView?.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        tableView?.endUpdates()
    }
    
    override func insert(object: T?, at index: Int) {
        guard let theObject = object else { return }
        
        let insertIndex = graphObjects.count - index
        totalCount += 1
        graphObjects.insert(theObject, at: insertIndex)
        
        tableView?.beginUpdates()
        tableView?.insertRows(at: [IndexPath(row: insertIndex, section: 1)], with: .none)
        tableView?.endUpdates()
    }
}

