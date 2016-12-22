//
//  PostController.swift
//  GuideSwift
//
//  Created by LuzanovRoman on 15.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

import UIKit

class PostController: BaseController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, NextCommentsCellDelegate, EdgeDownloaderDelegate {
    
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var creatorNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var postImageView: FileImageView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var commentPlaceholder: UILabel!
    @IBOutlet weak var commentTextView: UITextView!
    
    fileprivate var cellHeights = [String: CGFloat]()
    fileprivate var refreshControl: UIRefreshControl!
    fileprivate var comments: ReversedEdgeDownloader<EGFComment>?
    fileprivate var insertedCommentId: String?
    
    var currentPost: EGFPost?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = UIColor.white
        refreshControl.tintColor = UIColor.hexColor(0x5E66B1)
        tableView.refreshControl = refreshControl
        
        guard let post = currentPost, let postId = post.id, let headerView = tableView.tableHeaderView else { return }
        creatorNameLabel.text = post.creatorObject?.name?.fullName()
        descriptionLabel.text = post.desc
        postImageView.file = post.imageObject
        let headerHeight = FeedPostCell.height(forPost: post)
        headerView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: headerHeight)
        
        comments = ReversedEdgeDownloader(withSource: postId, edge: "comments", expand: ["creator"])
        comments?.pageCount = 5
        comments?.tableView = self.tableView
        comments?.delegate = self
        comments?.getNextPage()
    }
    
    fileprivate func updateSendButton() {
        commentPlaceholder.isHidden = !commentTextView.text.isEmpty
        sendButton.isEnabled = !commentTextView.text.isEmpty
    }
    
    @IBAction func sendComment(_ sender: AnyObject) {
        guard let text = commentTextView.text, let postId = currentPost?.id else { return }

        ProgressController.show()
        Graph.createObject(withParameters: ["text": text, "object_type": "comment"], forSource: postId, onEdge: "comments") { (object, error) in
            ProgressController.hide()
            
            guard let comment = object as? EGFComment else { return }
            self.insertedCommentId = comment.id
            self.commentTextView.text = ""
            self.updateSendButton()
            self.textViewDidChange(self.commentTextView)
        }
    }
    
    @IBAction func tapOnTableView(_ sender: AnyObject) {
        commentTextView.resignFirstResponder()
    }
    
    // MARK:- EdgeDownloaderDelegate
    func didInsert(graphObject: NSObject) {
        guard let theComments = comments, let comment = graphObject as? EGFComment, comment.id == insertedCommentId else { return }
        tableView.scrollToRow(at: IndexPath(row: theComments.count - 1, section: 1), at: .bottom, animated: true)
        insertedCommentId = nil
    }
    
    // MARK:- UITextViewDelegate
    func textViewDidChange(_ textView: UITextView) {
        let size = textView.sizeThatFits(CGSize(width: textView.frame.size.width, height: 1000))
        let newHeight = min(100, max(35.5, size.height))
        
        if (newHeight != textViewHeight.constant) {
            textViewHeight.constant = newHeight
            view.layoutIfNeeded()
            textView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        }
        updateSendButton()
    }
    
    // MARK:- UITableViewDelegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let control = refreshControl, control.isRefreshing == true {
            comments?.refreshList()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 {
            
            if let comment = comments?[indexPath.row], let commentId = comment.id {
                // Check if we already have the value
                if let value = cellHeights[commentId] { return value }
                
                let height = CommentCell.height(forComment: comment)
                cellHeights[commentId] = height
                return height
            }
        }
        return (comments?.isDownloaded ?? false) || (comments?.noAnyData ?? true) ? 0 : 50
    }

    // MARK:- UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : (comments?.count ?? 0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NextCommentsCell") as! NextCommentsCell
            cell.indicatorIsAnimated = comments?.isDownloading ?? false
            cell.delegate = self
            return cell
        }
        let comment = comments![indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
        cell.creatorNameLabel.text = comment.creatorObject?.name?.fullName()
        cell.descriptionLabel.text = comment.text
        return cell
    }
    
    // MARK:- NextCommentsCellDelegate
    func showNext() {
        guard let theComments = comments, !theComments.isDownloaded else { return }
        theComments.getNextPage()
    }
}
