//
//  OffendedUsersController.swift
//  GuideSwift
//
//  Created by LuzanovRoman on 09.01.17.
//  Copyright © 2017 eigengraph. All rights reserved.
//

import UIKit

class OffendedUsersController: BaseTableController {
    
    fileprivate var offendedUsers: EdgeDownloader<EGFUser>?
    var offensivePost: EGFPost?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "ProgressCell", bundle: nil), forCellReuseIdentifier: "ProgressCell")
        
        guard let postId = offensivePost?.id else { return }
        offendedUsers = EdgeDownloader(withSource: postId, edge: "offended", expand: [])
        offendedUsers?.tableView = tableView
        offendedUsers?.getNextPage()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? UserProfileController, let cell = sender as? OffendedUserCell {
            controller.profileUser = cell.offendedUser
        }
    }
    
    // MARK:- UITableViewDelegate
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let control = refreshControl, control.isRefreshing == true {
            offendedUsers?.refreshList()
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && offendedUsers?.isDownloaded == false {
            offendedUsers?.getNextPage()
        }
    }
    
    // MARK:- UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? (offendedUsers?.count ?? 0) : 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProgressCell") as! ProgressCell
            cell.indicatorIsHidden = tableView.refreshControl!.isRefreshing || (offendedUsers?.isDownloaded ?? true)
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "OffendedUserCell") as! OffendedUserCell
        cell.offendedUser = offendedUsers![indexPath.row]
        return cell
    }
}
