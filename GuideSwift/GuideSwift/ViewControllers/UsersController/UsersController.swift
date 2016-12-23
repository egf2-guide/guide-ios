//
//  UsersController.swift
//  GuideSwift
//
//  Created by LuzanovRoman on 20.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

import UIKit
import EGF2

class UsersController: BaseTableController, UserCellDelegate, UISearchBarDelegate {
    
    @IBOutlet var searchButton: UIBarButtonItem!
    
    fileprivate var activeDownloader: BaseDownloader<EGFUser>?
    fileprivate var searching: SearchDownloader<EGFUser>?
    fileprivate var follows: EdgeDownloader<EGFUser>?
    fileprivate let searchBar = UISearchBar()
    fileprivate let edge = "follows"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "ProgressCell", bundle: nil), forCellReuseIdentifier: "ProgressCell")
        tableView.register(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "UserCell")
        
        let parameters = EGF2SearchParameters(withObject: "user")
        parameters.fields = ["first_name","last_name"]
        searching = SearchDownloader(withParameters: parameters)

        searchBar.delegate = self
        searchBar.showsCancelButton = true
        searchBar.tintColor = UIColor.hexColor(0x5E66B1)
        
        Graph.userObject { (object, error) in
            guard let user = object as? EGFUser, let userId = user.id else { return }
            self.follows = EdgeDownloader(withSource: userId, edge: self.edge, expand: [])
            self.follows?.tableView = self.tableView
            self.follows?.getNextPage()
            self.activeDownloader = self.follows
        }
    }
    
    @IBAction func beginSearch(_ sender: AnyObject) {
        activeDownloader = searching
        activeDownloader?.tableView = tableView
        follows?.tableView = nil
        navigationItem.rightBarButtonItem = nil
        navigationItem.titleView = searchBar
        searchBar.becomeFirstResponder()
    }
    
    func endSearch() {
        activeDownloader = follows
        activeDownloader?.tableView = tableView
        searching?.tableView = nil
        searchBar.text = nil
        navigationItem.rightBarButtonItem = searchButton
        navigationItem.titleView = nil
    }
    
    // MARK:- UserCellDelegate
    func didTapFollowButton(withUser user: EGFUser, andCell cell: UserCell) {
        if Follows.shared.followState(forUser: user) == .isFollow {
            Follows.shared.unfollow(user: user) { cell.user = user }
        }
        else {
            Follows.shared.follow(user: user) { cell.user = user }
        }
        cell.user = user
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
        searching?.showObjects(withQuery: searchText)
    }
    
    // MARK:- UITableViewDelegate
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let control = refreshControl, control.isRefreshing == true else { return }
        activeDownloader?.refreshList()
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            if let downloader = activeDownloader, !downloader.isDownloaded {
                downloader.getNextPage()
            }
        }
    }
    
    // MARK:- UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return activeDownloader?.count ?? 0
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProgressCell") as! ProgressCell
            cell.indicatorIsHidden = tableView.refreshControl!.isRefreshing || (activeDownloader?.isDownloaded ?? true)
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell") as! UserCell
        cell.user = activeDownloader![indexPath.row]
        cell.delegate = self
        return cell
    }
}
