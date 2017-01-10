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
        guard let theObjects = objects else { return }
        
        let addAnimated = graphObjects.count > 0
        var indexPaths = [IndexPath]()
        
        for i in 0..<theObjects.count {
            indexPaths.append(IndexPath(row: i, section: 1))
        }
        totalCount = count
        
        for object in theObjects {
            graphObjects.insert(object, at: 0)
        }
        
        guard let tv = tableView else { return }
        
        if addAnimated {
            tv.beginUpdates()
            tv.insertRows(at: indexPaths, with: .none)
            tv.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
            tv.endUpdates()
        }
        else {
            tv.reloadData()
        }
    }
    
    override func replace(object: T) {
        guard let index = indexOf(object: object) else { return }
        graphObjects.replaceSubrange(index..<index + 1, with: [object])
        
        guard let tv = tableView else { return }
        delegate?.willUpdate?(graphObject: object)
        tv.beginUpdates()
        tv.reloadRows(at: [IndexPath(row: index, section: 1)], with: .none)
        tv.endUpdates()
        delegate?.didUpdate?(graphObject: object)
    }
    
    override func insert(object: T?, at index: Int) {
        guard let theObject = object, let objectId = theObject.value(forKey: "id") as? String else { return }
        
        // Check if object is already in the list
        if let _ = indexOfObject(withId: objectId) {
            return
        }
        let insertIndex = graphObjects.count - index
        totalCount += 1
        graphObjects.insert(theObject, at: insertIndex)
        
        guard let tv = tableView else { return }
        tv.beginUpdates()
        tv.insertRows(at: [IndexPath(row: insertIndex, section: 1)], with: .none)
        tv.endUpdates()
    }
    
    override func delete(object: T?) {
        guard let theObject = object, let index = graphObjects.index(of: theObject) else { return }
        totalCount -= 1
        graphObjects.remove(at: index)
        
        guard let tv = tableView else { return }
        tv.beginUpdates()
        tv.deleteRows(at: [IndexPath(row: index, section: 1)], with: .none)
        tv.endUpdates()
    }
}
