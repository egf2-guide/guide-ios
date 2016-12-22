//
//  EdgeDownloader.swift
//  GuideSwift
//
//  Created by LuzanovRoman on 22.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

import UIKit
import EGF2

@objc protocol EdgeDownloaderDelegate {
    func didInsert(graphObject: NSObject)
}

class EdgeDownloader<T: NSObject>: BaseDownloader<T> {
    
    weak var delegate: EdgeDownloaderDelegate?
    
    fileprivate var downloading = false
    fileprivate var expand: [String]
    fileprivate var source: String
    fileprivate var edge: String
    
    var pageCount = 25
    
    var isDownloading: Bool {
        get {
            return downloading
        }
    }
    
    var noAnyData: Bool {
        get {
            return totalCount == -1
        }
    }
    
    init(withSource source: String, edge: String, expand: [String]) {
        self.expand = expand
        self.source = source
        self.edge = edge
        super.init()
        self.addObservers()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK:- Private methods
    fileprivate func addObservers() {
        let object = Graph.notificationObject(forSource: source, andEdge: edge)
        NotificationCenter.default.addObserver(self, selector: #selector(edgeDidCreate(notification:)), name: .EGF2EdgeCreated, object: object)
    }
    
    func edgeDidCreate(notification: NSNotification) {
        guard let objectId = notification.userInfo?[EGF2EdgeObjectIdInfoKey] as? String else { return }

        Graph.refreshObject(withId: objectId, expand: expand) { (object, error) in
            guard let graphObject = object else { return }
            self.insert(object: graphObject as? T, at: 0)
            self.delegate?.didInsert(graphObject: graphObject)
        }
    }
    
    fileprivate func set(objects: [T]?, totalCount count: Int) {
        guard let theObjects = objects, let tv = tableView else { return }
        graphObjects.removeAll()
        tv.reloadData()
        add(objects: theObjects, totalCount: count)
    }
    
    func add(objects: [T]?, totalCount count: Int) {
        guard let theObjects = objects, let tv = tableView else { return }
        
        let start = graphObjects.count
        let end = start + theObjects.count
        var indexPaths = [IndexPath]()
        
        for i in start..<end {
            indexPaths.append(IndexPath(row: i, section: 0))
        }
        totalCount = count
        graphObjects.append(contentsOf: theObjects)
        
        tv.beginUpdates()
        tv.insertRows(at: indexPaths, with: .none)
        tv.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .none)
        tv.endUpdates()
    }
    
    func insert(object: T?, at index:Int) {
        guard let theObject = object, let tv = tableView else { return }
        
        totalCount += 1
        graphObjects.insert(theObject, at: index)
        
        tv.beginUpdates()
        tv.insertRows(at: [IndexPath(row: index, section: 0)], with: .none)
        tv.endUpdates()
    }
    
    // MARK:- Override
    override func refreshList() {
        if downloading { return }
        
        downloading = true
        Graph.refreshObjects(forSource: source, edge: edge, after: nil, expand: expand, count: pageCount) { (objects, count, error) in
            self.downloading = false
            self.tableView?.refreshControl?.endRefreshing()
            self.set(objects: objects as? [T], totalCount: count)
        }
    }
    
    override func getNextPage() {
        if downloading { return }
        
        downloading = true
        Graph.objects(forSource: source, edge: edge, after: self.last?.value(forKey: "id") as? String, expand: expand, count: pageCount) { (objects, count, error) in
            self.downloading = false
            self.add(objects: objects as? [T], totalCount: count)
        }
    }
}
