//
//  SearchDownloader.swift
//  GuideSwift
//
//  Created by LuzanovRoman on 22.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

import UIKit
import EGF2

class SearchDownloader<T: NSObject>: BaseDownloader<T> {

    var parameters: EGF2SearchParameters?

    fileprivate var searchToken = 0
    fileprivate var lastQuery: String?
    
    override var tableView: UITableView? {
        didSet {
            if tableView == nil {
                resetSearch(withTotalCount: 0)
                lastQuery = nil
            }
        }
    }
    
    init(withParameters parameters: EGF2SearchParameters) {
        self.parameters = parameters
        super.init()
        self.totalCount = 0
    }
    
    override func refreshList() {
        if let query = lastQuery, !query.isEmpty {
            resetSearch(withTotalCount: -1)
            showResults(withQuery: query)
        }
    }
    
    override func getNextPage() {
        if let query = lastQuery, !query.isEmpty {
            if graphObjects.count > 0 {
                showResults(withQuery: query)
            }
        }
    }
    
    fileprivate func resetSearch(withTotalCount count: Int) {
        searchToken += 1
        totalCount = count
        graphObjects.removeAll()
        tableView?.reloadData()
    }
    
    @objc fileprivate func showResults(withQuery query: String) {
        guard let params = parameters, let _ = tableView else { return }
        params.query = query
        
        let localSearchToken = searchToken
        let after = graphObjects.isEmpty ? -1 : graphObjects.count - 1
        
        Graph.search(withParameters: params, after: after, count: 50) { (objects, count, error) in
            // Ignore results of old requests
            if localSearchToken != self.searchToken { return }
            
            guard let theObjects = objects, let nextObjects = theObjects as? [T] else { return }
            
            self.totalCount = count
            self.graphObjects.append(contentsOf: nextObjects)
            self.tableView?.reloadData()
            
            if let control = self.tableView?.refreshControl, control.isRefreshing {
                control.endRefreshing()
            }
        }
    }
    
    func showObjects(withQuery query: String) {
        resetSearch(withTotalCount: query.isEmpty ? 0 : -1)
        
        if !query.isEmpty {
            let selector = #selector(showResults(withQuery:))
            
            if let object = lastQuery {
                NSObject.cancelPreviousPerformRequests(withTarget: self, selector: selector, object: object)
            }
            perform(selector, with: query, afterDelay: 0.5)
            lastQuery = query
        }
    }
}
