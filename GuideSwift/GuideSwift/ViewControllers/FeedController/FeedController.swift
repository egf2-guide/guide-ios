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

    fileprivate var posts: EdgeDownloader<EGFPost>?
    fileprivate var cellHeights = [String: CGFloat]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Graph.userObject { (object, error) in
            guard let user = object as? EGFUser, let userId = user.id else { return }
            self.posts = EdgeDownloader(withSource: userId, edge: "posts", expand: ["creator","image"])
            self.posts?.tableView = self.tableView
            self.posts?.getNextPage()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let postController = segue.destination as? PostController, let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
            postController.currentPost = posts?[indexPath.row]
        }
    }
    
    // MARK:- UITableViewDelegate
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let control = refreshControl, control.isRefreshing == true {
            posts?.refreshList()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if let post = posts?[indexPath.row], let postId = post.id {
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
        guard let thePosts = posts else { return }
        if indexPath.section == 1 && !thePosts.isDownloaded {
            thePosts.getNextPage()
        }
    }
    
    // MARK:- UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? (posts?.count ?? 0) : 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProgressCell") as! FeedProgressCell
            cell.indicatorIsHidden = posts?.isDownloaded ?? false
            return cell
        }
        let post = posts![indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! FeedPostCell
        cell.creatorNameLabel.text = post.creatorObject?.name?.fullName()
        cell.descriptionLabel.text = post.desc
        cell.postImageView.file = post.imageObject
        return cell
    }
}

