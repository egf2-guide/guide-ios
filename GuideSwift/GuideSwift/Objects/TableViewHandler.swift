//
//  TableViewHandler.swift
//  GuideSwift
//
//  Created by LuzanovRoman on 15.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

import UIKit

class TableViewHandler <T> {
    
    var graphObjects = [T]()
    var totalCount = -1
    weak var tableView: UITableView?
    
    init(withTableView tableView: UITableView) {
        self.tableView = tableView
    }
    
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
    
    var noAnyData: Bool {
        get {
            return totalCount == -1
        }
    }
    
    func set(objects: [T]?, totalCount count: Int) {
        guard let theObjects = objects else { return }
        graphObjects.removeAll()
        tableView?.reloadData()
        add(objects: theObjects, totalCount: count)
    }
    
    func add(objects: [T]?, totalCount count: Int) {
        guard let theObjects = objects else { return }
        
        let start = graphObjects.count
        let end = start + theObjects.count
        var indexPaths = [IndexPath]()
        
        for i in start..<end {
            indexPaths.append(IndexPath(row: i, section: 0))
        }
        totalCount = count
        graphObjects.append(contentsOf: theObjects)
        
        tableView?.beginUpdates()
        tableView?.insertRows(at: indexPaths, with: .none)
        tableView?.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .none)
        tableView?.endUpdates()
    }
    
    func insert(object: T?, at index:Int) {
        guard let theObject = object else { return }
        
        totalCount += 1
        graphObjects.insert(theObject, at: index)
        
        tableView?.beginUpdates()
        tableView?.insertRows(at: [IndexPath(row: index, section: 0)], with: .none)
        tableView?.endUpdates()
    }
}
