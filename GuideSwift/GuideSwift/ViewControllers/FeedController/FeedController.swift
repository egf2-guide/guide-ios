//
//  FeedController.swift
//  GuideSwift
//
//  Created by LuzanovRoman on 12.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

import UIKit
import EGF2

class FeedController: BaseTableController, PostCellDelegate, UISearchBarDelegate, BaseDownloaderDelegate {

    @IBOutlet var searchButton: UIBarButtonItem!
    @IBOutlet var newPostButton: UIBarButtonItem!
    @IBOutlet var listSegment: UISegmentedControl!
    
    fileprivate var searching: SearchDownloader<EGFPost>?
    fileprivate var timeline: EdgeDownloader<EGFPost>?
    fileprivate var feed: EdgeDownloader<EGFPost>?
    fileprivate let searchBar = UISearchBar()
    fileprivate var cellHeights = [String: CGFloat]()
    fileprivate var currentUserId: String?
    fileprivate let expand = ["creator","image"]
    fileprivate let edge = "posts"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "ProgressCell", bundle: nil), forCellReuseIdentifier: "ProgressCell")
        tableView.register(UINib(nibName: "PostCell", bundle: nil), forCellReuseIdentifier: "PostCell")
        
        let parameters = EGF2SearchParameters(withObject: "post")
        parameters.fields = ["desc"]
        parameters.expand = expand
        searching = SearchDownloader(withParameters: parameters)
        searching?.delegate = self
        
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        searchBar.tintColor = UIColor.hexColor(0x5E66B1)
        
        Graph.userObject { (object, error) in
            guard let user = object as? EGFUser, let userId = user.id else { return }
            self.currentUserId = userId
            self.timeline = EdgeDownloader(withSource: userId, edge: "timeline", expand: self.expand)
            self.timeline?.delegate = self
            self.feed = EdgeDownloader(withSource: userId, edge: self.edge, expand: self.expand)
            self.feed?.delegate = self
            self.feed?.tableView = self.tableView
            self.feed?.getNextPage()
            self.activeDownloader = self.feed
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !(searchBar.text ?? "").isEmpty {
            searchBar.becomeFirstResponder()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let postController = segue.destination as? PostController, let indexPath = sender as? IndexPath {
            postController.currentPost = activeDownloader?[indexPath.row]
            searchBar.resignFirstResponder()
        }
    }
    
    fileprivate var activeDownloader: BaseDownloader<EGFPost>? {
        willSet {
            if let oldDownloader = activeDownloader {
                oldDownloader.tableView = nil
            }
        }
        didSet {
            activeDownloader?.tableView = tableView
        }
    }
    
    @IBAction func changeList(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            activeDownloader = feed
        }
        else if sender.selectedSegmentIndex == 1 {
            activeDownloader = timeline
        }
    }
    
    // MARK:- BaseDownloaderDelegate
    func willUpdate(graphObject: NSObject) {
        guard let objectId = graphObject.value(forKey: "id") as? String else { return }
        self.cellHeights.removeValue(forKey: objectId)
    }
    
    // MARK:- Searching
    @IBAction func beginSearch(_ sender: AnyObject) {
        activeDownloader = searching
        navigationItem.rightBarButtonItem = nil
        navigationItem.leftBarButtonItem = nil
        navigationItem.titleView = searchBar
        searchBar.becomeFirstResponder()
    }
    
    func endSearch() {
        changeList(listSegment)
        searchBar.text = nil
        navigationItem.rightBarButtonItem = newPostButton
        navigationItem.leftBarButtonItem = searchButton
        navigationItem.titleView = listSegment
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
    
    // MARK:- PostCellDelegate
    var authorizedUserId: String? {
        get {
            return currentUserId
        }
    }
    
    func delete(post: EGFPost) {
        guard let postId = post.id, let userId = self.currentUserId else { return }
        
        showConfirm(withTitle: "Warning", message: "Really delete?") { 
            ProgressController.show()
            Graph.deleteObject(withId: postId, forSource: userId, fromEdge: self.edge) { (_, error) in
                ProgressController.hide()
            }
        }
    }
    
    // MARK:- UITableViewDelegate
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let control = refreshControl, control.isRefreshing == true {
            activeDownloader?.refreshList()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if let post = activeDownloader?[indexPath.row], let postId = post.id {
                // Check if we already have the value
                if let value = cellHeights[postId] { return value }
                
                let height = PostCell.height(forPost: post)
                cellHeights[postId] = height
                return height
            }
        }
        return 44
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let downloader = activeDownloader else { return }
        if indexPath.section == 1 && !downloader.isDownloaded {
            downloader.getNextPage()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowPost", sender: indexPath)
    }
    
    // MARK:- UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? (activeDownloader?.count ?? 0) : 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProgressCell") as! ProgressCell
            cell.indicatorIsHidden = tableView.refreshControl!.isRefreshing || (activeDownloader?.isDownloaded ?? true)
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
        cell.delegate = self
        cell.post = activeDownloader![indexPath.row]
        return cell
    }
}

