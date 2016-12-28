//
//  PostController.swift
//  GuideSwift
//
//  Created by LuzanovRoman on 15.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

import UIKit

class PostController: BaseController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, NextCommentsCellDelegate, CommentCellDelegate {
    
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var creatorNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var postImageView: FileImageView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var commentPlaceholder: UILabel!
    @IBOutlet weak var commentTextView: UITextView!
    
    fileprivate var cellHeights = [String: CGFloat]()
    fileprivate var refreshControl: UIRefreshControl!
    fileprivate var comments: ReversedEdgeDownloader<EGFComment>?
    fileprivate var editedComment: EGFComment?
    fileprivate var currentUser: EGFUser?
    fileprivate var edge = "comments"
    
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
        let headerHeight = PostCell.height(forPost: post)
        headerView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: headerHeight)
        
        comments = ReversedEdgeDownloader(withSource: postId, edge: edge, expand: ["creator"])
        comments?.pageCount = 5
        comments?.tableView = self.tableView
        comments?.getNextPage()
        
        Graph.userObject { (object, error) in
            guard let user = object as? EGFUser, let userId = user.id else { return }
            self.currentUser = user
            self.deleteButton.isHidden = (post.creator ?? "") != userId
        }
    }
    
    fileprivate func updateSendButton() {
        commentPlaceholder.isHidden = !commentTextView.text.isEmpty
        sendButton.isEnabled = commentTextView.text.characters.count > 1
    }
    
    @IBAction func deletePost(_ sender: AnyObject) {
        guard let postId = currentPost?.id, let userId = currentUser?.id else { return }
        
        showConfirm(withTitle: "Warning", message: "Really delete?") {
            ProgressController.show()
            Graph.deleteObject(withId: postId, forSource: userId, fromEdge: "posts") { (_, error) in
                ProgressController.hide()
                
                if error == nil {
                    _ = self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    @IBAction func sendComment(_ sender: AnyObject) {
        if let comment = editedComment {
            guard let commentId = comment.id, let text = commentTextView.text else { return }
            
            ProgressController.show()
            Graph.updateObject(withId: commentId, parameters: ["text":text]) { (object, error) in
                ProgressController.hide()
                
                if error == nil {
                    comment.text = self.commentTextView.text
                    self.endEditing()
                    self.updateSendButton()
                    self.textViewDidChange(self.commentTextView)
                    self.cellHeights.removeValue(forKey: commentId)
                    
                    if let index = self.comments?.graphObjects.index(of: comment) {
                        self.tableView.reloadRows(at: [IndexPath(row: index, section: 1)], with: .none)
                        self.tableView.scrollToRow(at: IndexPath(row: index, section: 1), at: .bottom, animated: true)
                    }
                }
            }
            return
        }
        guard let text = commentTextView.text, let postId = currentPost?.id else { return }

        ProgressController.show()
        Graph.createObject(withParameters: ["text": text, "object_type": "comment"], forSource: postId, onEdge: "comments") { (object, error) in
            ProgressController.hide()
            
            guard let comment = object as? EGFComment, let theComments = self.comments else { return }
            comment.creatorObject = self.currentUser
            self.comments?.insert(object: comment, at: 0)
            self.commentTextView.text = ""
            self.updateSendButton()
            self.textViewDidChange(self.commentTextView)
            self.tableView.scrollToRow(at: IndexPath(row: theComments.count - 1, section: 1), at: .bottom, animated: true)
        }
    }
    
    @IBAction func tapOnTableView(_ sender: AnyObject) {
        commentTextView.resignFirstResponder()
    }
    
    fileprivate func startEditing(witComment comment: EGFComment) {
        editedComment = comment
        sendButton.setTitle("Update", for: .normal)
        commentTextView.text = comment.text
        commentTextView.becomeFirstResponder()
        textViewDidChange(commentTextView)
        updateSendButton()
        
        if let index = self.comments?.graphObjects.index(of: comment) {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(300)) {
                self.tableView.scrollToRow(at: IndexPath(row: index, section: 1), at: .bottom, animated: true)
            }
        }
    }
    
    fileprivate func endEditing() {
        editedComment = nil
        sendButton.setTitle("Send", for: .normal)
        commentTextView.text = ""
        textViewDidChange(commentTextView)
        updateSendButton()
    }
    
    // MARK:- CommentCellDelegate
    var authorizedUserId: String? {
        get {
            return currentUser?.id
        }
    }
    
    func delete(comment: EGFComment) {
        guard let commentId = comment.id, let postId = currentPost?.id else { return }
        
        showConfirm(withTitle: "Warning", message: "Really delete?") {
            ProgressController.show()
            Graph.deleteObject(withId: commentId, forSource: postId, fromEdge: self.edge) { (_, error) in
                ProgressController.hide()
            }
        }
    }
    
    func edit(comment: EGFComment) {
        startEditing(witComment: comment)
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
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if let _ = editedComment {
            endEditing()
        }
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
        cell.delegate = self
        cell.comment = comments![indexPath.row]
        return cell
    }
    
    // MARK:- NextCommentsCellDelegate
    func showNext() {
        guard let theComments = comments, !theComments.isDownloaded else { return }
        theComments.getNextPage()
    }
}
