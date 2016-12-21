//
//  UsersController.swift
//  GuideSwift
//
//  Created by LuzanovRoman on 20.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

import UIKit
import EGF2

class UsersController: BaseTableController, SearchingHandlerDelegate, UserCellDelegate {
    
    fileprivate var isSearching = false
    fileprivate var searchingHandler: SearchingHandler<EGFUser>!
    fileprivate var follows: TableViewHandler<EGFUser>!
    fileprivate var currentUserId: String?
    fileprivate var isDownloading = false
    fileprivate let edge = "follows"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // TODO remove
        tabBarController?.selectedIndex = 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "ProgressCell", bundle: nil), forCellReuseIdentifier: "ProgressCell")
        tableView.register(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "UserCell")
        
        let parameters = EGF2SearchParameters(withObject: "user")
        parameters.fields = ["first_name","last_name"]
        
        searchingHandler = SearchingHandler(withTableViewController: self, parameters: parameters)
        follows = TableViewHandler(withTableView: tableView)
        
        Graph.userObject { (object, error) in
            self.currentUserId = (object as? EGFUser)?.id
            self.getNextPage()
        }
    }
    
    fileprivate func refreshList() {
        if isSearching {
            searchingHandler.refreshList()
        }
        else {
            guard let source = currentUserId else { return }
            if isDownloading { return }
            
            isDownloading = true
            Graph.refreshObjects(forSource: source, edge: edge) { (objects, count, error) in
                self.isDownloading = false
                
                if !self.isSearching {
                    self.refreshControl?.endRefreshing()
                    self.follows.set(objects: objects as? [EGFUser], totalCount: count)
                }
            }
        }
    }
    
    fileprivate func getNextPage() {
        guard let source = currentUserId else { return }
        if isDownloading { return }
        
        isDownloading = true
        Graph.objects(forSource: source, edge: edge, after: follows.last?.id) { (objects, count, error) in
            self.isDownloading = false
            
            if !self.isSearching {
                self.follows.add(objects: objects as? [EGFUser], totalCount: count)
            }
        }
    }
    
    // MARK:- UserCellDelegate
    func didTapFollowButton(withUser user: EGFUser) {
        // TODO
    }
    
    // MARK:- SearchingHandlerDelegate
    func searchWillBegin() {
        isSearching = true
    }
    
    func searchDidEnd() {
        isSearching = false
        tableView.reloadData()
    }
    
    // MARK:- UITableViewDelegate
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let control = refreshControl, control.isRefreshing == true {
            refreshList()
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            if isSearching {
                if !searchingHandler.isDownloaded {
                    searchingHandler.getNextPage()
                }
            }
            else {
                if !follows.isDownloaded && !isDownloading {
                    getNextPage()
                }
            }
        }
    }
    
    // MARK:- UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return isSearching ? searchingHandler.count : follows.count
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProgressCell") as! ProgressCell
            cell.indicatorIsHidden = tableView.refreshControl!.isRefreshing || (isSearching ? searchingHandler.isDownloaded : follows.isDownloaded)
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell") as! UserCell
        cell.user = isSearching ? searchingHandler[indexPath.row] : follows[indexPath.row]
        cell.delegate = self
        return cell
    }
}
