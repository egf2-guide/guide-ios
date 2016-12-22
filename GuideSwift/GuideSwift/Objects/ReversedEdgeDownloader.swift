//
//  ReversedEdgeDownloader.swift
//  GuideSwift
//
//  Created by LuzanovRoman on 22.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

import UIKit

class ReversedEdgeDownloader<T: NSObject>: EdgeDownloader<T> {
    
    override var last: T? {
        get {
            return graphObjects.first
        }
    }
    
    override func add(objects: [T]?, totalCount count: Int) {
        guard let theObjects = objects, let tv = tableView else { return }
        
        var indexPaths = [IndexPath]()
        
        for i in 0..<theObjects.count {
            indexPaths.append(IndexPath(row: i, section: 1))
        }
        totalCount = count
        
        for object in theObjects {
            graphObjects.insert(object, at: 0)
        }
        tv.beginUpdates()
        tv.insertRows(at: indexPaths, with: .none)
        tv.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        tv.endUpdates()
    }
    
    override func insert(object: T?, at index: Int) {
        guard let theObject = object, let tv = tableView else { return }
        
        let insertIndex = graphObjects.count - index
        totalCount += 1
        graphObjects.insert(theObject, at: insertIndex)
        
        tv.beginUpdates()
        tv.insertRows(at: [IndexPath(row: insertIndex, section: 1)], with: .none)
        tv.endUpdates()
    }
}
