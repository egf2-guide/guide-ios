//
//  SearchingHandler.swift
//  GuideSwift
//
//  Created by LuzanovRoman on 21.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

import UIKit
import EGF2

protocol SearchingHandlerDelegate {
    func searchWillBegin()
    func searchDidEnd()
}

class SearchingHandler <T:NSObject> : NSObject, UISearchBarDelegate {
    
    var graphObjects = [T]()
    var parameters: EGF2SearchParameters?
    
    fileprivate var searchButton: UIBarButtonItem?
    fileprivate let searchBar = UISearchBar()
    fileprivate var totalCount = 0
    fileprivate var searchToken = 0
    fileprivate var lastQuery: String?
    
    weak var tableViewController: UITableViewController?
    
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
    
    subscript(index: Int) -> T {
        get {
            return graphObjects[index]
        }
    }
    
    init(withTableViewController tableViewController: UITableViewController, parameters: EGF2SearchParameters) {
        super.init()
        self.tableViewController = tableViewController
        self.parameters = parameters
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        searchBar.tintColor = UIColor.hexColor(0x5E66B1)
        searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(beginSearch))
        self.tableViewController?.navigationItem.rightBarButtonItem = searchButton
    }
    
    func refreshList() {
        if let query = lastQuery, !query.isEmpty {
            resetSearch(withTotalCount: -1)
            showResults(withQuery: query)
        }
    }
    
    func getNextPage() {
        if let query = lastQuery, !query.isEmpty {
            if graphObjects.count > 0 {
                showResults(withQuery: query)
            }
        }
    }
    
    func beginSearch() {
        if let delegate = tableViewController as? SearchingHandlerDelegate {
            delegate.searchWillBegin()
        }
        tableViewController?.navigationItem.rightBarButtonItem = nil
        tableViewController?.navigationItem.titleView = searchBar
        searchBar.becomeFirstResponder()
        tableViewController?.tableView.reloadData()
        tableViewController?.tableView.refreshControl?.endRefreshing()
    }
    
    func endSearch() {
        lastQuery = nil
        totalCount = 0
        searchBar.text = nil
        tableViewController?.navigationItem.rightBarButtonItem = searchButton
        tableViewController?.navigationItem.titleView = nil
        graphObjects.removeAll()
        tableViewController?.tableView.reloadData()
        
        if let delegate = tableViewController as? SearchingHandlerDelegate {
            delegate.searchDidEnd()
        }
    }
    
    fileprivate func resetSearch(withTotalCount count: Int) {
        searchToken += 1
        totalCount = count
        graphObjects.removeAll()
        tableViewController?.tableView.reloadData()
    }
    
    func showResults(withQuery query: String) {
        guard let params = parameters else { return }
        params.query = query
        
        let localSearchToken = searchToken
        let after = graphObjects.isEmpty ? -1 : graphObjects.count - 1

        Graph.search(withParameters: params, after: after, count: 50) { (objects, count, error) in
            // Ignore results of old requests
            if localSearchToken != self.searchToken { return }
            
            guard let theObjects = objects, let nextObjects = theObjects as? [T] else { return }
            
            self.totalCount = count
            self.graphObjects.append(contentsOf: nextObjects)
            self.tableViewController?.tableView.reloadData()
            
            if let control = self.tableViewController?.refreshControl, control.isRefreshing {
                control.endRefreshing()
            }
        }
    }
    
    // MARK:- UISearchBarDelegate
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        endSearch()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if let text = searchBar.text, text.isEmpty {
            endSearch()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        resetSearch(withTotalCount: searchText.isEmpty ? 0 : -1)
        
        if !searchText.isEmpty {
            let selector = #selector(showResults(withQuery:))
            
            if let object = lastQuery {
                NSObject.cancelPreviousPerformRequests(withTarget: self, selector: selector, object: object)
            }
            perform(selector, with: searchText, afterDelay: 0.5)
            lastQuery = searchText
        }
    }
}
