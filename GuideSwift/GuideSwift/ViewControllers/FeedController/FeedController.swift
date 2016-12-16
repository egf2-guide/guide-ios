//
//  FeedController.swift
//  GuideSwift
//
//  Created by LuzanovRoman on 12.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

import UIKit
import EGF2

class FeedController: BaseTableController {

    fileprivate var posts: TableViewHandler<EGFPost>!
    fileprivate var currentUserId: String?
    fileprivate var isDownloading = false
    fileprivate let expand = ["creator","image"]
    fileprivate let edge = "posts"
    fileprivate var cellHeights = [String: CGFloat]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        posts = TableViewHandler(withTableView: tableView)

        Graph.userObject { (object, error) in
            self.currentUserId = (object as? EGFUser)?.id
            self.addObservers()
            self.getNextPage()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    fileprivate func addObservers() {
        guard let source = currentUserId else { return }
        let object = Graph.notificationObject(forSource: source, andEdge: edge)
        NotificationCenter.default.addObserver(self, selector: #selector(edgeDidCreate(notification:)), name: .EGF2EdgeCreated, object: object)
    }
    
    func edgeDidCreate(notification: NSNotification) {
        guard let postId = notification.userInfo?[EGF2EdgeObjectIdInfoKey] as? String else { return }
        
        // It's better to refresh object because 'post.imageObject.dimensions' can be nil right after creation of image
        Graph.refreshObject(withId: postId, expand: expand) { (object, error) in
            self.posts.insert(object: object as? EGFPost, at: 0)
        }
    }
    
    fileprivate func refreshPosts() {
        guard let source = currentUserId else { return }
        if isDownloading { return }
        
        isDownloading = true
        Graph.refreshObjects(forSource: source, edge: edge, after: nil, expand: expand) { (objects, count, error) in
            self.isDownloading = false
            self.refreshControl?.endRefreshing()
            self.posts.set(objects: objects as? [EGFPost], totalCount: count)
        }
    }
    
    fileprivate func getNextPage() {
        guard let source = currentUserId else { return }
        if isDownloading { return }
        
        isDownloading = true
        Graph.objects(forSource: source, edge: edge, after: posts.last?.id, expand: expand) { (objects, count, error) in
            self.isDownloading = false
            self.posts.add(objects: objects as? [EGFPost], totalCount: count)
        }
    }
    
    // MARK:- UITableViewDelegate
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let control = refreshControl, control.isRefreshing == true {
            refreshPosts()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            let post = posts[indexPath.row]
            
            if let postId = post.id {
                // Check if we already have the value
                if let value = cellHeights[postId] { return value }
                
                let height = FeedPostCell.height(forPost: post)
                cellHeights[postId] = height
                return height
            }
        }
        return 44
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && !posts.isDownloaded && isDownloading == false {
            getNextPage()
        }
    }
    
    // MARK:- UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? posts.count : 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProgressCell") as! FeedProgressCell
            cell.indicatorIsHidden = posts.isDownloaded
            return cell
        }
        let post = posts[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! FeedPostCell
        cell.creatorNameLabel.text = post.creatorObject?.name?.fullName()
        cell.descriptionLabel.text = post.desc
        cell.postImageView.file = post.imageObject
        return cell
    }
}

