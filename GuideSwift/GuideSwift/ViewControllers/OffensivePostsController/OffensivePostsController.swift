//
//  OffensivePostsController.swift
//  GuideSwift
//
//  Created by LuzanovRoman on 09.01.17.
//  Copyright © 2017 eigengraph. All rights reserved.
//

import UIKit

class OffensivePostsController: BaseTableController, OffensivePostCellDelegate {

    fileprivate var offensivePosts: EdgeDownloader<EGFPost>?
    fileprivate var cellHeights = [String: CGFloat]()
    fileprivate var currentUserId: String?
    fileprivate var currentRoleId: String?
    fileprivate let expand = ["creator", "image"]
    fileprivate let edge = "offending_posts"

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "ProgressCell", bundle: nil), forCellReuseIdentifier: "ProgressCell")

        Graph.userObject { (object, _) in
            guard let user = object as? EGFUser, let userId = user.id else { return }
            self.currentUserId = userId

            Graph.objects(forSource: userId, edge: "roles") { (objects, _, _) in
                guard let roles = objects else { return }

                for role in roles {
                    if let adminRole = role as? EGFAdminRole {
                        guard let roleId = adminRole.id else { return }
                        self.currentRoleId = roleId
                        self.offensivePosts = EdgeDownloader(withSource: roleId, edge: self.edge, expand: self.expand)
                        self.offensivePosts?.tableView = self.tableView
                        self.offensivePosts?.getNextPage()
                        break
                    }
                }
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? OffendedUsersController, let cell = sender as? OffensivePostCell {
            controller.offensivePost = cell.post
        }
    }

    // MARK: - OffensivePostCellDelegate
    func delete(post: EGFPost) {
        guard let roleId = currentRoleId, let postId = post.id else { return }

        ProgressController.show()
        Graph.deleteObject(withId: postId, forSource: roleId, fromEdge: edge) { (_, _) in
            ProgressController.hide()
        }
    }

    func confirmAsOffensive(post: EGFPost) {
        guard let postId = post.id, let creatorId = post.creator else { return }

        ProgressController.show()
        Graph.deleteObject(withId: postId, forSource: creatorId, fromEdge: "posts") { (_, error) in
            ProgressController.hide()

            if error == nil {
                self.delete(post: post)
            }
        }
    }

    // MARK: - UITableViewDelegate
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let control = refreshControl, control.isRefreshing == true {
            offensivePosts?.refreshList()
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if let post = offensivePosts?[indexPath.row], let postId = post.id {
                // Check if we already have the value
                if let value = cellHeights[postId] { return value }

                let height = OffensivePostCell.height(forPost: post)
                cellHeights[postId] = height
                return height
            }
        }
        return 44
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let downloader = offensivePosts else { return }
        if indexPath.section == 1 && !downloader.isDownloaded {
            downloader.getNextPage()
        }
    }

    // MARK: - UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? (offensivePosts?.count ?? 0) : 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProgressCell") as! ProgressCell
            cell.indicatorIsHidden = tableView.refreshControl!.isRefreshing || (offensivePosts?.isDownloaded ?? true)
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "OffensivePostCell") as! OffensivePostCell
        cell.delegate = self
        cell.post = offensivePosts![indexPath.row]
        return cell
    }
}
