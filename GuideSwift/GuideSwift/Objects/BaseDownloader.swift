//
//  BaseDownloader.swift
//  GuideSwift
//
//  Created by LuzanovRoman on 22.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

import UIKit
import EGF2

@objc protocol BaseDownloaderDelegate {
    @objc optional func willUpdate(graphObject: NSObject)
    @objc optional func didUpdate(graphObject: NSObject)
}

class BaseDownloader <T: NSObject>: NSObject {

    var graphObjects = [T]()
    var totalCount = -1

    weak var delegate: BaseDownloaderDelegate?
    weak var tableView: UITableView? {
        didSet {
            if let theTableView = tableView {
                theTableView.reloadData()
                theTableView.refreshControl?.endRefreshing()
            }
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    subscript(index: Int) -> T {
        get {
            return graphObjects[index]
        }
    }

    var last: T? {
        return graphObjects.last
    }

    var count: Int {
        return graphObjects.count
    }

    var isDownloaded: Bool {
        return graphObjects.count == totalCount
    }

    func indexOfObject(withId id: String) -> Int? {
        for i in 0..<graphObjects.count {
            if let objectId = graphObjects[i].value(forKey: "id") as? String, objectId == id {
                return i
            }
        }
        return nil
    }

    func indexOf(object: T) -> Int? {
        guard let id = object.value(forKey: "id") as? String else { return nil }
        return indexOfObject(withId: id)
    }

    func replace(object: T) {
        guard let index = indexOf(object: object) else { return }
        graphObjects.replaceSubrange(index..<index + 1, with: [object])

        guard let tv = tableView else { return }
        delegate?.willUpdate?(graphObject: object)
        tv.beginUpdates()
        tv.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
        tv.endUpdates()
        delegate?.didUpdate?(graphObject: object)
    }

    // MARK: - Override
    var expandValues: [String] {
        return []
    }

    func refreshList() {
        // Override this
    }

    func getNextPage() {
        // Override this
    }
}
