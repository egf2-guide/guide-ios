//
//  EdgeDownloader.swift
//  GuideSwift
//
//  Created by LuzanovRoman on 22.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

import UIKit
import EGF2

class EdgeDownloader<T: NSObject>: BaseDownloader<T> {

    fileprivate var subscribedObjectIds = [String]()
    fileprivate var downloading = false
    fileprivate var expand: [String]
    fileprivate var source: String
    fileprivate var edge: String

    var pageCount = 25

    var isDownloading: Bool {
        return downloading
    }

    var noAnyData: Bool {
        return totalCount == -1
    }

    init(withSource source: String, edge: String, expand: [String]? = nil) {
        self.expand = expand ?? []
        self.source = source
        self.edge = edge
        super.init()
        Graph.addObserver(self, selector: #selector(edgeCreated(notification:)), name: .EGF2EdgeCreated, forSource: source, andEdge: edge)
        Graph.addObserver(self, selector: #selector(edgeRemoved(notification:)), name: .EGF2EdgeRemoved, forSource: source, andEdge: edge)
    }
    
    deinit {
        Graph.removeObserver(self)
    }

    // MARK: - Private methods
    func edgeCreated(notification: NSNotification) {
        guard let objectId = notification.userInfo?[EGF2EdgeObjectIdInfoKey] as? String else { return }

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(100)) { [weak self] in
            guard let strongSelf = self else { return }
            Graph.addObserver(strongSelf, selector: #selector(strongSelf.objectUpdated(notification:)), name: .EGF2ObjectUpdated, forSource: objectId)
            Graph.object(withId: objectId, expand: strongSelf.expand) { (object, _) in
                guard let graphObject = object else { return }
                strongSelf.insert(object: graphObject as? T, at: 0)
            }
        }
    }

    func edgeRemoved(notification: NSNotification) {
        guard let objectId = notification.userInfo?[EGF2EdgeObjectIdInfoKey] as? String else { return }
        guard let index = indexOfObject(withId: objectId) else { return }
        delete(at: index)
        Graph.removeObserver(self, name: .EGF2ObjectUpdated, fromSource: objectId)
        subscribedObjectIds.remove(objectId)
    }
    
    func objectUpdated(notification: NSNotification) {
        guard let objectId = notification.userInfo?[EGF2ObjectIdInfoKey] as? String else { return }

        Graph.object(withId: objectId, expand: expandValues) { (object, _) in
            guard let updatedObject = object as? T else { return }
            self.replace(object: updatedObject)
        }
    }

    fileprivate func set(objects: [T]?, totalCount count: Int) {
        guard let theObjects = objects else { return }
        graphObjects.removeAll()

        if let tv = tableView {
            tv.reloadData()
        }
        add(objects: theObjects, totalCount: count)
    }

    func add(objects: [T]?, totalCount count: Int) {
        guard let theObjects = objects else { return }

        let addAnimated = graphObjects.count > 0
        let start = graphObjects.count
        let end = start + theObjects.count
        var indexPaths = [IndexPath]()

        for i in start..<end {
            indexPaths.append(IndexPath(row: i, section: 0))
        }
        totalCount = count
        graphObjects.append(contentsOf: theObjects)

        guard let tv = tableView else { return }

        if addAnimated {
            tv.beginUpdates()
            tv.insertRows(at: indexPaths, with: .none)
            tv.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .none)
            tv.endUpdates()
        } else {
            tv.reloadData()
        }
        updateSubscriptions(forObjects: theObjects)
    }
    
    func updateSubscriptions(forObjects objects: [T]) {
        var newSubscribedObjectIds = [String]()
        
        for object in objects {
            guard let objectId = object.value(forKey: "id") as? String else { return }
            if subscribedObjectIds.contains(objectId) { return }
            newSubscribedObjectIds.append(objectId)
        }
        if newSubscribedObjectIds.count > 0 {
            Graph.addObserver(self, selector: #selector(objectUpdated(notification:)), name: .EGF2ObjectUpdated, forSources: newSubscribedObjectIds)
        }
    }

    func insert(object: T?, at index: Int) {
        guard let theObject = object, let objectId = theObject.value(forKey: "id") as? String else { return }

        // Check if object is already in the list
        if let _ = indexOfObject(withId: objectId) {
            return
        }
        totalCount += 1
        graphObjects.insert(theObject, at: index)

        guard let tv = tableView else { return }
        tv.beginUpdates()
        tv.insertRows(at: [IndexPath(row: index, section: 0)], with: .none)
        tv.endUpdates()
    }

    func delete(at index: Int) {
        if graphObjects.count == 0 || graphObjects.count <= index { return }
        totalCount -= 1
        graphObjects.remove(at: index)
        
        guard let tv = tableView else { return }
        tv.beginUpdates()
        tv.deleteRows(at: [IndexPath(row: index, section: 0)], with: .none)
        tv.endUpdates()
    }
    
    func delete(object: T?) {
        guard let theObject = object, let index = graphObjects.index(of: theObject) else { return }
        delete(at: index)
    }

    // MARK: - Override
    override var expandValues: [String] {
        return expand
    }

    override func refreshList() {
        if downloading { return }

        downloading = true
        Graph.refreshObjects(forSource: source, edge: edge, after: nil, expand: expand, count: pageCount) { (objects, count, _) in
            self.downloading = false
            self.tableView?.refreshControl?.endRefreshing()
            self.set(objects: objects as? [T], totalCount: count)
        }
    }

    override func getNextPage() {
        if downloading { return }

        downloading = true
        Graph.objects(forSource: source, edge: edge, after: self.last?.value(forKey: "id") as? String, expand: expand, count: pageCount) { (objects, count, _) in
            self.downloading = false
            self.add(objects: objects as? [T], totalCount: count)
        }
    }
}
