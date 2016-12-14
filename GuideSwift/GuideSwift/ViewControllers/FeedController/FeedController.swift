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

    fileprivate var posts = [EGFPost]()
    fileprivate var currentUserId: String?
    fileprivate var postCount = -1
    fileprivate var isDownloading = false
    fileprivate let expand = ["creator","image"]
    fileprivate let edge = "posts"
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        
        Graph.object(withId: postId, expand: expand) { (object, error) in
            guard let post = object as? EGFPost else { return }
            self.postCount += 1
            self.posts.insert(post, at: 0)
            self.tableView.reloadData()
        }
    }
    
    fileprivate func refreshPosts() {
        guard let source = currentUserId else { return }
        if isDownloading { return }
        
        isDownloading = true
        Graph.refreshObjects(forSource: source, edge: edge, after: nil, expand: expand) { (objects, count, error) in
            self.isDownloading = false
            
            self.refreshControl?.endRefreshing()
            guard let nextPosts = objects as? [EGFPost] else { return }
            self.posts.removeAll()
            self.add(nextPosts: nextPosts, count: count)
        }
    }
    
    fileprivate func getNextPage() {
        guard let source = currentUserId else { return }
        if isDownloading { return }
        
        isDownloading = true
        Graph.objects(forSource: source, edge: edge, after: posts.last?.id, expand: expand) { (objects, count, error) in
            self.isDownloading = false
            
            guard let nextPosts = objects as? [EGFPost] else { return }
            self.add(nextPosts: nextPosts, count: count)
        }
    }
    
    fileprivate func add(nextPosts: [EGFPost], count: Int) {
        postCount = count
        posts.append(contentsOf: nextPosts)
        tableView.reloadData()
    }
    
    // MARK:- UITableViewDelegate
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let control = refreshControl, control.isRefreshing == true {
            refreshPosts()
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && posts.count != postCount && isDownloading == false {
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
            cell.indicatorIsHidden = posts.count == postCount
            return cell
        }
        let post = posts[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! FeedPostCell
        cell.creatorNameLabel.text = post.creatorObject?.name?.fullName()
        cell.descriptionLabel.text = post.desc
        cell.postImage = nil
        cell.post = post
        
        if let file = post.imageObject {
            SimpleFileManager.shared.image(withFile: file) { (postImage, fromCache) in
                // We must be ensure we show appropriate image for cell
                if post !== cell.post { return }
                
                guard let image = postImage else { return }
                cell.postImage = image
                
                if !fromCache {
                    tableView.beginUpdates()
                    tableView.endUpdates()
                }
            }
        }
        return cell
    }
}

