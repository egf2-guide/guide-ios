//
//  UserProfileController.swift
//  GuideSwift
//
//  Created by LuzanovRoman on 27.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

import UIKit

class UserProfileController: BaseController, UITableViewDelegate, UITableViewDataSource, PostCellDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var followButton: FollowButton!

    fileprivate var cellHeights = [String: CGFloat]()
    fileprivate var refreshControl: UIRefreshControl!
    fileprivate var feed: EdgeDownloader<EGFPost>?
    fileprivate var currentUserId: String?
    
    var profileUser: EGFUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "ProgressCell", bundle: nil), forCellReuseIdentifier: "ProgressCell")
        tableView.register(UINib(nibName: "PostCell", bundle: nil), forCellReuseIdentifier: "PostCell")
        
        refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = UIColor.white
        refreshControl.tintColor = UIColor.hexColor(0x5E66B1)
        tableView.refreshControl = refreshControl

        userNameLabel.text = profileUser?.name?.fullName()
        followButton.user = profileUser
        
        Graph.userObject { (object, error) in
            self.currentUserId = (object as? EGFUser)?.id
            
            guard let profileUserId = self.profileUser?.id else { return }
            self.feed = EdgeDownloader(withSource: profileUserId, edge: "posts", expand: ["creator", "image"])
            self.feed?.tableView = self.tableView
            self.feed?.getNextPage()
        }
    }
    
    @IBAction func followUser(_ sender: AnyObject) {
        guard let user = profileUser else { return }
        
        if Follows.shared.followState(forUser: user) == .isFollow {
            Follows.shared.unfollow(user: user) { self.followButton.checkFollowState() }
        }
        else {
            Follows.shared.follow(user: user) { self.followButton.checkFollowState() }
        }
        followButton.checkFollowState()
    }
    
    // MARK:- PostCellDelegate
    var authorizedUserId: String? {
        get {
            return currentUserId
        }
    }
    
    func delete(post: EGFPost) {
        guard let postId = post.id, let userId = currentUserId else { return }
        
        showConfirm(withTitle: "Warning", message: "Really delete?") {
            ProgressController.show()
            Graph.deleteObject(withId: postId, forSource: userId, fromEdge: "posts") { (_, error) in
                ProgressController.hide()
            }
        }
    }
    
    // MARK:- UITableViewDelegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let control = refreshControl, control.isRefreshing == true {
            feed?.refreshList()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if let post = feed?[indexPath.row], let postId = post.id {
                // Check if we already have the value
                if let value = cellHeights[postId] { return value }
                
                let height = PostCell.height(forPost: post)
                cellHeights[postId] = height
                return height
            }
        }
        return 44
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section != 0 { return }
        
        if let controller = storyboard?.instantiateViewController(withIdentifier: "PostController") as? PostController {
            controller.currentPost = feed?[indexPath.row]
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    // MARK:- UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? (feed?.count ?? 0) : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProgressCell") as! ProgressCell
            cell.indicatorIsHidden = tableView.refreshControl!.isRefreshing || (feed?.isDownloaded ?? true)
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
        cell.delegate = self
        cell.post = feed![indexPath.row]
        return cell
    }
}
